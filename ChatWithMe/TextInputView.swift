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
        HStack {
            TextField("Type here...", text: $message, axis: .vertical)
                .padding()
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                .padding(.leading)
                .focused($isKeyboardActive)
                .lineLimit(1...)
                .padding(.trailing, !message.isEmpty ? 0 : 15)
            if !message.isEmpty {
                makeButton(action: action)
                    .frame(maxHeight: 60)
            }
        }
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
                .frame(width: 35)
                .padding(.trailing)
        }
        .disabled(message.isEmpty)
    }
}


#Preview {
    @State var message = "dsaf"
    return TextInputView(message: $message, action: {})
}
