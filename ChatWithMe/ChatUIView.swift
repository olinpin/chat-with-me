//
//  ChatUIView.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import SwiftUI

struct ChatUIView: View {
    @Binding var responses: [(Users, String)]
    var body: some View {
        GeometryReader { geo in
            
            ScrollView {
                ForEach(responses, id: \.self.1) { actor, message in
                    var messageColor = actor == Users.AI ? Color.blue : Color.green
                    HStack {
                        if actor == Users.User {
                            Spacer(minLength: geo.size.width / 4)
                        }
                        Text("\(actor): \(message)")
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(messageColor)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
//                            .frame(maxWidth: geo.size.width * 2 / 3)
                        if actor == Users.AI {
                            Spacer(minLength: geo.size.width / 4)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}

#Preview {
    @State var responses: [(Users, String)] = [(Users.User, "Hi"), (Users.AI, "Hello"), (Users.User, "What can you do?")]
    return ChatUIView(responses: $responses)
}
