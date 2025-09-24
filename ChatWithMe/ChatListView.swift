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
        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.timestamp, ascending: false)],
        animation: .default)
    private var allChats: FetchedResults<Chat>

    private var chatsWithContent: [Chat] {
        allChats.filter { $0.shouldBePersisted }
    }

    private func createNewChat() {
        let newChat = Chat(context: viewContext)
        newChat.timestamp = Date()
        newChat.name = "New Chat"
        newChat.id = UUID()
        newChatToNavigateTo = newChat
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(chatsWithContent, id: \.id) { chat in
                NavigationLink(destination: {
                    ContentView(chat: chat)
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chat.name ?? chat.displayName)
                            .font(.headline)
                        if let firstResponse = chat.responses.first {
                            Text(firstResponse.text)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
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
        .onAppear {
            cleanupEmptyChats()
        }
    }
    
    private func cleanupEmptyChats() {
        let emptyChats = allChats.filter { !$0.shouldBePersisted }
        for emptyChat in emptyChats {
            viewContext.delete(emptyChat)
        }

        if !emptyChats.isEmpty {
            do {
                try viewContext.save()
                print("Cleaned up \(emptyChats.count) empty chats")
            } catch {
                print("Error cleaning up empty chats: \(error)")
            }
        }
    }
}

#Preview {
    ChatListView()
}
