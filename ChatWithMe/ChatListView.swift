//
//  ChatListView.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 24.09.2025.
//

import SwiftUI

struct ChatListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var navigationPath = NavigationPath()
    @State private var newChatToNavigateTo: Chat?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.timestamp, ascending: true)],
        animation: .default)
    private var chats: FetchedResults<Chat>

    private func createNewChat() {
        let newChat = Chat(context: viewContext)
        newChat.timestamp = Date()
        newChat.name = "New Chat"
        newChat.id = UUID()
        newChatToNavigateTo = newChat
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(chats) { chat in
                NavigationLink(destination: {
                    ContentView(chat: chat)
                }) {
                    Text(chat.name ?? "No name chat")
                }
            }
            .navigationTitle(Text("Chats"))
            .navigationDestination(item: $newChatToNavigateTo) { chat in
                ContentView(chat: chat)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: createNewChat) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
}

#Preview {
    ChatListView()
}
