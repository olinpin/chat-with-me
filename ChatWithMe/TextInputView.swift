//
//  TextInputView.swift
//  ChatWithMe
//
//  Created by Oliver Hnát on 21.09.2025.
//

import SwiftUI

struct TextInputView: View {
    @Binding var message: String
    var action: () -> ()
    @FocusState var isKeyboardActive: Bool
    var body: some View {
        ZStack {
                TextField("Type here...", text: $message)
                    .padding()
                    .background(.gray.opacity(0.5))
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    .focused($isKeyboardActive)
            HStack {
                Spacer()
                makeButton(action: action)
            }
        }
        .frame(maxHeight: 60)
    }
    // button function builder
    @ViewBuilder
    private func makeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .overlay {
                    Image(systemName: "arrow.up")
                        .foregroundStyle(.white)
                        .bold()
                }
                .padding()
                .padding(.trailing)
        }
        .disabled(message.isEmpty)
    }
}
