//
//  ChatWithMeApp.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import SwiftUI

@main
struct ChatWithMeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
