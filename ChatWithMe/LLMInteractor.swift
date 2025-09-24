//
//  LLMInteractor.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import Foundation
import FoundationModels
import SwiftUI

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
            var text = ""
            for response in responses {
                text.append("\(response.userType): \(response.text)\n")
            }
            print(text)
            let session = LanguageModelSession(model: LLMInteractor.model, instructions: "You are a summarizer model. Your job is to take in a transcript of a chat and summarize it in MAXIMUM of 5 words.")
            
            return try await session.respond(to: text).content
        } catch {
            print(error)
        }
        return ""
    }

}
