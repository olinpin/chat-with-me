//
//  LLMInteractor.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import Foundation
import FoundationModels

class LLMInteractor {
    
    static let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    
    static func query(for query: String, session: LanguageModelSession, completion: @escaping (Result<String, Error>) -> Void) async {
        do {
            print(query)
            let response = try await session.respond(to: query)
            return completion(.success(response.content))
        } catch {
            print("\(error)")
        }
    }
    
    static func query(for query: String, completion: @escaping (Result<String, Error>) -> Void) async {
        return completion(.success(String(repeating: "Response ", count: [1...100].randomElement()?.lowerBound ?? 5)))
    }

}


enum Users {
    case User, AI
}
