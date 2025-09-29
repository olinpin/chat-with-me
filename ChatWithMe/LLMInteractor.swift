//
//  LLMInteractor.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import Foundation
import FoundationModels
import SwiftUI

@Generable(description: "A short chat name with maximum 5 words")
struct ChatName {
    @Guide(description: "Chat summary in maximum 5 words")
    var name: String
}

@MainActor
class LLMInteractor: ObservableObject {
    
    @Published var output: String = ""
    @Published var isStreaming = false
    static let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)

    func query(for query: String, session: LanguageModelSession) {
        Task {
            isStreaming = true
            output = ""
            do {
                let response = session.streamResponse(to: query)
                for try await partial in response {
                    output = partial.content
                }
            } catch {
                print(error)
            }
            isStreaming = false
        }
    }
    
    func createName(for chat: Chat) async -> String {
        do {
            let responses = chat.responses
            var filteredText = ""

            // Filter out potentially problematic messages
            for response in responses {
                // Skip empty messages
                let trimmedText = response.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedText.isEmpty else { continue }

                // Use a separate session to check if the message is appropriate for processing
                if await isContentAppropriate(trimmedText) {
                    filteredText.append("\(response.userType): \(trimmedText)\n")
                }
            }

            // If no appropriate content found, return a default name
            guard !filteredText.isEmpty else {
                return "Chat"
            }

            let session = LanguageModelSession(
                model: LLMInteractor.model,
                instructions: """
                    You are a summarizer model. Create a concise chat name based on the conversation content.
                    CRITICAL REQUIREMENT: The chat name MUST be exactly 5 words or fewer. Never exceed 5 words.
                    
                    Count each word carefully before responding.
                    Examples of valid names: "Weather Chat", "Travel Planning", "Work Discussion", "Family Updates", "Tech Support"
                    """
            )

            let response = try await session.respond(to: filteredText, generating: ChatName.self)
            let generatedName = response.content.name
            
            // Enforce 5-word limit as a final safety check
            let finalName = enforceWordLimit(generatedName, maxWords: 5)
            return finalName
            
        } catch {
            print("Error creating name: \(error)")
        }
        return "Chat"
    }
    
    private func enforceWordLimit(_ text: String, maxWords: Int) -> String {
        let words = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        // If within limit, return as-is
        if words.count <= maxWords {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // If exceeds limit, take only the first maxWords
        let truncatedWords = Array(words.prefix(maxWords))
        let truncatedName = truncatedWords.joined(separator: " ")
        
        print("Warning: Generated name '\(text)' exceeded \(maxWords) words. Truncated to: '\(truncatedName)'")
        
        return truncatedName
    }

    private func isContentAppropriate(_ text: String) async -> Bool {
        do {
            // Create a session specifically for content filtering
            let filterSession = LanguageModelSession(
                model: LLMInteractor.model,
                instructions: """
                    You are a content filter. Your job is to determine if text is appropriate for summarization.
                    Respond with exactly "YES" if the text is appropriate (no profanity, hate speech, explicit content, or harmful material).
                    Respond with exactly "NO" if the text contains inappropriate content.
                    Be conservative - when in doubt, respond "NO".
                    """
            )

            let response = try await filterSession.respond(
                to: "Is this text appropriate for summarization? Text: \(text)")
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                == "YES"
        } catch {
            print("Error filtering content: \(error)")
            // If filtering fails, err on the side of caution and exclude the content
            return false
        }
    }

}
