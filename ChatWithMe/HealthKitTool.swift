//
//  HealthKitTool.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 29.09.2025.
//

import Foundation
import FoundationModels

struct HealthKitTool: Tool {
    let name = "getHealth"
    let description = "Get step length from Apple Health"
    let healthKitManager = HealthKitManager()
    
    @Generable
    struct Arguments {
        @Guide(description: "The healthkit attribute you want to get data for")
        var attribute: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        print(arguments)
        await healthKitManager.requestAccess()
        return await healthKitManager.getStepLength()?.description ?? "No step length found"
    }
}
