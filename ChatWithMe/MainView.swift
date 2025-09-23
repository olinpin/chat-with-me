//
//  MainView.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 24.09.2025.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        NavigationView {
            ChatListView()
        }
    }
}

#Preview {
    MainView()
}
