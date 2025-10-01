//
//  CalculatorTool.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 01.10.2025.
//

import Foundation
import FoundationModels

struct CalculatorTool: Tool {
    let name = "calculate"
    let description = "Calculates the result of a simple arithmetic expression"
    
    @Generable
    enum Operation: String, Codable, CaseIterable {
        case addition = "+"
        case subtraction = "-"
        case multiplication = "*"
        case division = "/"
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "First number in the operation")
        var firstNumber: Double
        @Guide(description: "Second number in the operation")
        var secondNumber: Double
        @Guide(description: "The operation to perform")
        var operation: Operation
    }
    
    func call(arguments: Arguments) async throws -> String {
        print("Used calculator tool with arguments: \(arguments)")
        switch arguments.operation {
        case .addition:
            return "\(arguments.firstNumber + arguments.secondNumber)"
        case .subtraction:
            return "\(arguments.firstNumber - arguments.secondNumber)"
        case .multiplication:
            return "\(arguments.firstNumber * arguments.secondNumber)"
        case .division:
            return "\(arguments.firstNumber / arguments.secondNumber)"
        }
    }
}
