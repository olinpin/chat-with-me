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
    @NSManaged public var timestamp: Date

    // Computed property to work with the enum
    var user: Users {
        get {
            return Users(rawValue: userType) ?? .User
        }
        set {
            userType = newValue.rawValue
        }
    }
}

extension Chat {
    public var responses: [AiResponse] {
        let set = transcript as? Set<AiResponse> ?? []
        return set.sorted {
            $0.timestamp < $1.timestamp
        }
    }

    var hasContent: Bool {
        return responses.contains {
            !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var shouldBePersisted: Bool {
        return hasContent
    }

    var displayName: String {
        if let name = name, !name.isEmpty, name != "New Chat" {
            return name
        }

        if let firstUserMessage = responses.first(where: { $0.user == .User }) {
            let trimmed = firstUserMessage.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return String(trimmed.prefix(50))
            }
        }

        return "New Chat"
    }
}
