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
    
    static func query(for query: String, completion: @escaping (Result<String, Error>) -> Void) async {
        return completion(.success(String(repeating: "Response ", count: [1...100].randomElement()?.lowerBound ?? 5)))
    }

}
