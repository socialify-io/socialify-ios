//
//  DMView.swift
//  DMView
//
//  Created by Tomasz on 22/08/2021.
//

import SwiftUI
import SocialifySdk
import CoreData

struct DMView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var currentAccount: Account?
    
    let receiver: User
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(.systemGray6)
    
    @State private var message = ""
    @State var messages: [DM] = []
    
    @State private var sameSenderInARow: CGFloat = 0
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
                    ForEach(Array(messages.enumerated()), id: \.element) { index, message in
                        if(message.username != currentAccount?.username) {
                            VStack {
                                if(index == 0 || messages[index-1].username != message.username) {
                                    HStack {
                                        Spacer()
                                            .frame(width: 44)
                                        
                                        Text(message.username ?? "<username can't be loaded>")
                                            .font(.caption)
                                            .foregroundColor(Color("CustomForegroundColor"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 18)
                                    }.padding(.bottom, -2)
                                    Spacer()
                                }
                                
                                
                                HStack {
                                    if(messages.count-1 == index || messages.count-1 > index && messages[index+1].username != message.username) {
                                        VStack {
                                            Image(systemName: "person.circle.fill")
                                                .renderingMode(.template)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 40)
                                                .foregroundColor(.accentColor)
                                                .padding(.trailing, 4)
                                        }
                                    } else {
                                        VStack {
                                            Spacer()
                                                .frame(width: 44)
                                        }
                                    }
                                    
                                    HStack {
                                        Text(message.message ?? "<message can't be loaded>")
                                    }.padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(Color("CustomAppearanceItemColor"))
                                    .cornerRadius(20)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                    
                                    Spacer()
                                }
                                Spacer()
                            }.id(index)
                        } else {
                            HStack {
                                Spacer()
                                
                                HStack {
                                    Text(message.message ?? "<message can't be loaded>")
                                }.padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color("CustomAppearanceItemColor"))
                                .cornerRadius(20)
                                .shadow(color: Color("ShadowColor"), radius: 5)
                                .padding(.trailing, 5)
                            }.id(index)
                        }
                    }
                }.onChange(of: messages.count) { _ in
                    value.scrollTo(messages.count - 1)
                }
            }
            Spacer()
            HStack {
                TextField("Text here...", text: $message)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                
                Button(action: {
                    if(message != "") {
                        SocketIOManager.sharedInstance.sendDM(message: message, id: receiver.id)
                        message = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 8)
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
            self.currentAccount = client.getCurrentAccount()
            self.messages = SocketIOManager.sharedInstance.getDMsFromDB(user: receiver)
            print(messages)
            
            SocketIOManager.sharedInstance.getDMMessage() { response in
                if(response.receiverId == receiver.id && response.senderId == currentAccount?.userId || response.receiverId == currentAccount?.userId && response.senderId == receiver.id) {
                    self.messages.append(response)
                }
           }
        }
        .onDisappear {
            SocketIOManager.sharedInstance.stopReceivingMessages()
        }
    }
}

//struct DMView_Previews: PreviewProvider {
//    static var previews: some View {
//        DMView()
//    }
//}
