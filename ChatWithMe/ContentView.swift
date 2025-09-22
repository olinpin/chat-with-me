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
    
    @State private var currentChat: LanguageModelSession = LanguageModelSession(model: LLMInteractor.model, instructions: "You are a language model. I can help you with anything. Just ask me anything. I'm here to help!")
    @State private var message: String = ""
    @State var responses: [(Users, String)] = []
    
    var body: some View {
        VStack {
            ChatUIView(responses: $responses)
            TextInputView(message: $message, action: askAI)
        }
    }

    private func askAI() {
        let currentMessage = message
        message = ""
        Task {
            responses.append((Users.User, currentMessage))
            await LLMInteractor.query(for: currentMessage, session: currentChat) { response in
//            await LLMInteractor.query(for: message) { response in
                switch response {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let res):
                    responses.append((Users.AI, res))
                }
            }
        }
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

#Preview {
    @State var responses: [(Users, String)] = [(Users.User, "Hi"), (Users.AI, "Hello"), (Users.User, "What can you do?"), (Users.User, "Hi"), (Users.AI, "Hello"), (Users.User, "What can you do?"), (Users.User, "Lorem ipsum is a standard, meaningless placeholder or dummy text used in graphic design, publishing, and web development to demonstrate the visual form of a document's layout or a typeface without distracting viewers with actual content. The text is derived from classical Latin but is scrambled and intentionally incoherent. Purpose Demonstrate layout: It shows how text will fit into a design, allowing designers to focus on typography, font choices, and visual hierarchy. Avoid distraction: By using text without meaning, the viewer's attention is kept on the design rather than the content being displayed. Origin Classical Latin: The words originate from a Latin text titled De finibus bonorum et malorum (meaning the ends of good and evil) by Cicero. An unknown printer: In the 1500s, an unknown printer scrambled parts of this text to create a type specimen book to showcase different fonts. Modern use: It gained popularity in the 1960s with Letraset sheets and was further popularized by desktop publishing software like Aldus PageMaker. How it works Scrambled text: The original Latin words are manipulated and rearranged. Mimics real text: The resulting text looks like natural language with varied word lengths and a typical frequency of letters and punctuation, even though it's not real Latin. Incoherent meaning: The text is not meant to be read or understood, serving only a visual purpose."), (Users.AI, "Lorem ipsum is a standard, meaningless placeholder or dummy text used in graphic design, publishing, and web development to demonstrate the visual form of a document's layout or a typeface without distracting viewers with actual content. The text is derived from classical Latin but is scrambled and intentionally incoherent. Purpose Demonstrate layout: It shows how text will fit into a design, allowing designers to focus on typography, font choices, and visual hierarchy. Avoid distraction: By using text without meaning, the viewer's attention is kept on the design rather than the content being displayed. Origin Classical Latin: The words originate from a Latin text titled De finibus bonorum et malorum (meaning the ends of good and evil) by Cicero. An unknown printer: In the 1500s, an unknown printer scrambled parts of this text to create a type specimen book to showcase different fonts. Modern use: It gained popularity in the 1960s with Letraset sheets and was further popularized by desktop publishing software like Aldus PageMaker. How it works Scrambled text: The original Latin words are manipulated and rearranged. Mimics real text: The resulting text looks like natural language with varied word lengths and a typical frequency of letters and punctuation, even though it's not real Latin. Incoherent meaning: The text is not meant to be read or understood, serving only a visual purpose.")]
    ContentView(responses: responses).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
