//
//  RoomView.swift
//  RoomView
//
//  Created by Tomasz on 10/08/2021.
//

import SwiftUI
import SocialifySdk
import CoreData

struct RoomView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var currentAccount: Account?
    
    let room: Room
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(.systemGray6)
   
    @State private var message = ""
    
    @State private var sameSenderInARow: CGFloat = 0
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    private var fetchRequest: FetchRequest<Message>
    private var messages: FetchedResults<Message> { fetchRequest.wrappedValue }
   
    init(room: Room) {
        self.room = room
        
        self.fetchRequest = FetchRequest(
            entity: Message.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Message.id,
                    ascending: true)
            ],
            predicate: NSPredicate(format: "room == %@", room.roomId as! CVarArg)
        )
    }
    
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
                                        
                                        if messages.count-1 == index || messages.count-1 > index && messages[index+1].username != message.username {
                                            VStack {
                                                Image(systemName: "person.circle.fill")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 32)
                                                    .foregroundColor(.accentColor)
                                                    .padding(.trailing, 4)
                                            }
                                        } else {
                                            VStack {
                                                Spacer()
                                                    .frame(width: 36)
                                            }
                                        }
                                        
                                        HStack {
                                            Text(message.message ?? "<message can't be loaded>")
                                                .font(.callout)
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
                                            .font(.callout)
                                    }.padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(Color("CustomAppearanceItemColor"))
                                    .cornerRadius(20)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                    .padding(.trailing, 5)
                                }.id(index)
                            }
                    }
                }
                .onChange(of: messages.count) { _ in
                    value.scrollTo(messages.count - 1)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        value.scrollTo(messages.count - 1)
                    }
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
                        SocketIOManager.sharedInstance.sendMessage(roomId: room.roomId as! Int, message: message)
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
        //.background(Color("BackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            self.currentAccount = client.getCurrentAccount()
            SocketIOManager.sharedInstance.connectRoom(roomId: room.roomId as! Int)
        }
    }
}
//
//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView(roomId: 0)
//    }
//}
