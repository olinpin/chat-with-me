//
//  HealthKitManager.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 29.09.2025.
//
import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    let allTypes: Set = [
        HKQuantityType(.walkingSpeed),
        HKQuantityType(.walkingStepLength),
        HKQuantityType(.stepCount)
    ]

    var stepLength: Double?
    
    var stepCount: Int?

    func requestAccess() async {
        do {
            if HKHealthStore.isHealthDataAvailable() {
                try await healthStore.requestAuthorization(toShare: Set(), read: allTypes)
            }
        } catch {
            fatalError(
                "Something went wrong while requesting healthKit permissions: \(error.localizedDescription)"
            )
        }
    }

    func getStepLength() async -> Double? {
        if stepLength != nil {
            return stepLength
        }
        let stepLengthType = HKQuantityType(.walkingStepLength)

        let query = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: stepLengthType),
            options: .discreteAverage)
        // maybe make an average of all the ones gotten in the last week?
        do {
            let results = try await query.result(for: healthStore)
            stepLength = results?.averageQuantity()?.doubleValue(for: HKUnit.meter())
            return stepLength
        } catch {
            fatalError(
                "Something went wrong while getting step length from healthKit: \(error.localizedDescription)"
            )
        }
    }
    
//    func getCurrentStepCount() async -> Double? {
//        let stepCountType = HKQuantityType(.stepCount)
//
//        let query = HKStatisticsQueryDescriptor(
//            predicate: HKSamplePredicate.quantitySample(type: stepCountType),
//            options: .cumulativeSum)
//
//        do {
//            let results = try await query.result(for: healthStore)
//            stepCount = results?.sumQuantity().val
//            return stepCount
//        } catch {
//            fatalError(
//                "Something went wrong while getting step length from healthKit: \(error.localizedDescription)"
//            )
//        }
//    }

}
