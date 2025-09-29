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
    var walkingSpeed: Double?

    func requestAccess() async -> Bool {
        do {
            if HKHealthStore.isHealthDataAvailable() {
                try await healthStore.requestAuthorization(toShare: Set(), read: allTypes)
                return true
            } else {
                print("HealthKit is not available on this device")
                return false
            }
        } catch {
            print("Error requesting HealthKit permissions: \(error.localizedDescription)")
            return false
        }
    }
    
    func isAuthorizedForAllTypes() -> Bool {
        for type in allTypes {
            let status = healthStore.authorizationStatus(for: type)
            if status != .sharingAuthorized {
                return false
            }
        }
        return true
    }
    
    private func createLastWeekPredicate() -> NSPredicate {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
    }
    
    private func getAverageQuantity(for quantityType: HKQuantityType, unit: HKUnit) async throws -> Double? {
        let datePredicate = createLastWeekPredicate()
        
        let query = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: quantityType, predicate: datePredicate),
            options: .discreteAverage)
        
        let results = try await query.result(for: healthStore)
        return results?.averageQuantity()?.doubleValue(for: unit)
    }

    func getStepLength() async -> Double? {
        if stepLength != nil {
            return stepLength
        }
        
        do {
            stepLength = try await getAverageQuantity(
                for: HKQuantityType(.walkingStepLength),
                unit: HKUnit.meter()
            )
            return stepLength
        } catch {
            print("Error getting step length from HealthKit: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getWalkingSpeed() async -> Double? {
        if walkingSpeed != nil {
            return walkingSpeed
        }
        
        do {
            walkingSpeed = try await getAverageQuantity(
                for: HKQuantityType(.walkingSpeed),
                unit: HKUnit(from: "m/s")
            )
            return walkingSpeed
        } catch {
            print("Error getting walking speed from HealthKit: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getTodaysStepCount() async -> Int? {
        do {
            let sampleType = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(
                withStart: Calendar.current.startOfDay(for: Date()),
                end: Date(),
                options: .strictStartDate
            )
            
            let query = HKStatisticsQueryDescriptor(
                predicate: HKSamplePredicate.quantitySample(type: sampleType, predicate: predicate),
                options: .cumulativeSum
            )
            
            let results = try await query.result(for: healthStore)
            if let sum = results?.sumQuantity() {
                return Int(sum.doubleValue(for: HKUnit.count()))
            }
        } catch {
            print("Error getting step count from HealthKit: \(error.localizedDescription)")
        }
        return nil
    }
}
