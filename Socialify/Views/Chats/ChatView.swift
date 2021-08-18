//
//  ChatView.swift
//  ChatView
//
//  Created by Tomasz on 10/08/2021.
//

import SwiftUI
import SocialifySdk
import CoreData

struct ChatView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let chat: Room
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(.systemGray6)
    
    @State private var message = ""
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField("Text here...", text: $message)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                
                Button(action: { SocketIOManager.sharedInstance.send(message: message, room: chat) }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                }
                Spacer()
            }.shadow(color: Color("ShadowColor"), radius: 5)
        }.padding()
        .background(Color("BackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            SocketIOManager.sharedInstance.join(roomId: chat.roomId ?? "")
        }
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
