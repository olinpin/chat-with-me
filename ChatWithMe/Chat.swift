//
//  Chat.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 23.09.2025.
//

import Foundation
import CoreData

enum Users: String, CaseIterable {
    case User = "user"
    case AI = "ai"
}

@objc(AiResponse)
public class AiResponse: NSManagedObject {
    
    @NSManaged public var userType: String
    @NSManaged public var text: String
    @NSManaged public var id: UUID
    
    // Computed property to work with the enum
    var user: Users {
        get {
            return Users(rawValue: userType) ?? .User
        }
        set {
            userType = newValue.rawValue
        }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Set default values when creating a new instance
        if id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
            id = UUID()
        }
    }
}
