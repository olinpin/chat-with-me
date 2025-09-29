//
//  ChatUIView.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import SwiftUI

struct ChatUIView: View {
    @ObservedObject var chat: Chat
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ForEach(chat.responses, id: \.id) { res in
                    let actor = res.user
                    let message = res.text
                    let messageColor = actor == Users.AI ? Color.blue : Color.green
                    HStack {
                        if actor == Users.User {
                            Spacer(minLength: geo.size.width / 4)
                        }
                        Text("\(message)")
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
            .defaultScrollAnchor(.bottom)
            .defaultScrollAnchor(.top, for: .alignment)
        }
    }
}
