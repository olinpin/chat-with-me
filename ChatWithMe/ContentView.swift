//
//  ContentView.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import SwiftUI
import CoreData
import FoundationModels

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var currentChat: LanguageModelSession = LanguageModelSession(model: LLMInteractor.model, tools: [HealthKitTool()], instructions: "You are a language model. I can help you with anything. Just ask me anything. I'm here to help!")
    @State private var message: String = ""
    @StateObject var llmInteractor = LLMInteractor()
    @FocusState var isKeyboardActive: Bool
    @ObservedObject var chat: Chat

    
    var body: some View {
        VStack {
            ChatUIView(chat: chat)
                .onTapGesture {
                    isKeyboardActive = false
                }
            TextInputView(message: $message, action: askAI, isKeyboardActive: _isKeyboardActive)
        }
        .onChange(of: llmInteractor.output) { oldValue, newValue in
            if !newValue.isEmpty && !chat.responses.isEmpty {
                let lastIndex = chat.responses.count - 1
                if chat.responses[lastIndex].user == Users.AI {
                    let updatedResponse = chat.responses[lastIndex]
                    updatedResponse.text = newValue
                    // Explicitly mark the chat as changed for Core Data
                    chat.objectWillChange.send()
                }
            }
        }
        .onChange(of: llmInteractor.isStreaming) { oldValue, newValue in
            if oldValue {
                Task {
                    let name = await llmInteractor.createName(for: chat)
                    if name != chat.name {
                        chat.name = name
                    }
                    self.tryToSave()
                }
            }
        }
        .onDisappear {
            if !chat.shouldBePersisted {
                viewContext.delete(chat)
                do {
                    try viewContext.save()
                    print("Deleted empty chat on view disappear")
                } catch {
                    print("Error deleting empty chat: \(error)")
                }
            }
        }
    }
    
    private func tryToSave() {
        if chat.shouldBePersisted {
            do {
                chat.timestamp = Date()
                try viewContext.save()
                print("saving chat with content")
            } catch {
                print(error)
            }
        } else {
            print("skipping save - chat has no content")
        }
    }

    private func askAI() {
        let currentMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !currentMessage.isEmpty else {
            return
        }

        message = ""
        if chat.transcript == nil {
            chat.transcript = NSSet()
        }

        let userRes = AiResponse(context: viewContext)
        userRes.userType = Users.User.rawValue
        userRes.id = UUID()
        userRes.timestamp = Date()
        userRes.text = currentMessage

        let AIRes = AiResponse(context: viewContext)
        AIRes.userType = Users.AI.rawValue
        AIRes.id = UUID()
        AIRes.timestamp = Date()
        AIRes.text = ""

        chat.addToTranscript(userRes)
        chat.addToTranscript(AIRes)

        self.tryToSave()
        llmInteractor.query(for: currentMessage, session: currentChat)
    }
    
    
    //    private func addItem() {
    //        withAnimation {
    //            let newItem = Item(context: viewContext)
    //            newItem.timestamp = Date()
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
    //
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            offsets.map { items[$0] }.forEach(viewContext.delete)
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
}

//#Preview {
//    @State var responses: [AiResponse] = [
//    AiResponse(user: Users.User, text: "Hi"),
//	AiResponse(user: Users.AI, text: "Hello"),
//	AiResponse(user: Users.User, text: "What can you do?"),
//	AiResponse(user: Users.User, text: "Hi"),
//	AiResponse(user: Users.AI, text: "Hello"),
//	AiResponse(user: Users.User, text: "What can you do?"),
//	AiResponse(user: Users.User, text: "Lorem ipsum is a standard, meaningless placeholder or dummy text used in graphic design, publishing, and web development to demonstrate the visual form of a document's layout or a typeface without distracting viewers with actual content. The text is derived from classical Latin but is scrambled and intentionally incoherent. Purpose Demonstrate layout: It shows how text will fit into a design, allowing designers to focus on typography, font choices, and visual hierarchy. Avoid distraction: By using text without meaning, the viewer's attention is kept on the design rather than the content being displayed. Origin Classical Latin: The words originate from a Latin text titled De finibus bonorum et malorum (meaning the ends of good and evil) by Cicero. An unknown printer: In the 1500s, an unknown printer scrambled parts of this text to create a type specimen book to showcase different fonts. Modern use: It gained popularity in the 1960s with Letraset sheets and was further popularized by desktop publishing software like Aldus PageMaker. How it works Scrambled text: The original Latin words are manipulated and rearranged. Mimics real text: The resulting text looks like natural language with varied word lengths and a typical frequency of letters and punctuation, even though it's not real Latin. Incoherent meaning: The text is not meant to be read or understood, serving only a visual purpose."),
//	AiResponse(user: Users.AI, text: "Lorem ipsum is a standard, meaningless placeholder or dummy text used in graphic design, publishing, and web development to demonstrate the visual form of a document's layout or a typeface without distracting viewers with actual content. The text is derived from classical Latin but is scrambled and intentionally incoherent. Purpose Demonstrate layout: It shows how text will fit into a design, allowing designers to focus on typography, font choices, and visual hierarchy. Avoid distraction: By using text without meaning, the viewer's attention is kept on the design rather than the content being displayed. Origin Classical Latin: The words originate from a Latin text titled De finibus bonorum et malorum (meaning the ends of good and evil) by Cicero. An unknown printer: In the 1500s, an unknown printer scrambled parts of this text to create a type specimen book to showcase different fonts. Modern use: It gained popularity in the 1960s with Letraset sheets and was further popularized by desktop publishing software like Aldus PageMaker. How it works Scrambled text: The original Latin words are manipulated and rearranged. Mimics real text: The resulting text looks like natural language with varied word lengths and a typical frequency of letters and punctuation, even though it's not real Latin. Incoherent meaning: The text is not meant to be read or understood, serving only a visual purpose.")
//    ]
//    ContentView(responses: responses).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
