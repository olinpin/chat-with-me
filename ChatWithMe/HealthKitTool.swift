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
    let description = "Get step length or walking speed from Apple Health"
    let healthKitManager = HealthKitManager()
    
    @Generable
    enum HealthAttribute: String, CaseIterable {
        case stepLength = "step length"
        case walkingSpeed = "walking speed"
        case stepCount = "step count"
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The healthkit attribute you want to get data for. Choose from: step length or walking speed")
        var attribute: HealthAttribute
    }
    
    func call(arguments: Arguments) async throws -> String {
        print(arguments)
        await healthKitManager.requestAccess()
        
        switch arguments.attribute {
        case .stepLength:
            return await healthKitManager.getStepLength()?.description ?? "No step length found"
        case .walkingSpeed:
            return await healthKitManager.getWalkingSpeed()?.description ?? "No walking speed found"
        case .stepCount:
            return await healthKitManager.getTodaysStepCount()?.description ?? "No step count found"
        }
    }
}
