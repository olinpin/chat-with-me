//
//  Playground.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 22.09.2025.
//

import Playgrounds
import FoundationModels
import Foundation

#Playground {
    let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    let session = LanguageModelSession(model: model, instructions: "You're a language model")
    let response = try await session.respond(to: "Hi")
}
