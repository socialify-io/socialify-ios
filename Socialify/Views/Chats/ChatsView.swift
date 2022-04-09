//
//  ChatsView.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI
import SocialifySdk
import CoreData
import SocketIO

struct ChatTileView: View {
    
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    var calendar = Calendar.current
    let chat: Chat
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    private var messagesFetchRequest: FetchRequest<Message>
    private var dmsFetchRequest: FetchRequest<DM>
    
    private var messages: FetchedResults<Message> { messagesFetchRequest.wrappedValue }
    private var dms: FetchedResults<DM> { dmsFetchRequest.wrappedValue }
   
    init(chat: Chat) {
        self.chat = chat
        
        self.messagesFetchRequest = FetchRequest(
            entity: Message.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Message.id,
                    ascending: false)
            ],
            predicate: NSPredicate(format: "room == %@", NSNumber(value: chat.chatId))
        )
        
        let predicateForReceivedMessageReceived = NSPredicate(format: "receiverId == %@", NSNumber(value: SocialifyClient.shared.getCurrentAccount().userId))
        let predicateForSendMessageReceived = NSPredicate(format: "receiverId == %@", NSNumber(value: chat.chatId))
        let predicateForSendMessageSend = NSPredicate(format: "senderId == %@", NSNumber(value: SocialifyClient.shared.getCurrentAccount().userId))
        let predicateForReceivedMessageSend = NSPredicate(format: "senderId == %@", NSNumber(value: chat.chatId))
        
        let predicateAndReceived = NSCompoundPredicate(type: .and, subpredicates: [predicateForReceivedMessageSend, predicateForReceivedMessageReceived])
        let predicateAndSend = NSCompoundPredicate(type: .and, subpredicates: [predicateForSendMessageSend, predicateForSendMessageReceived])
        
        let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateAndSend, predicateAndReceived])
        
        self.dmsFetchRequest = FetchRequest(
            entity: DM.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \DM.id,
                    ascending: false)
            ],
            predicate: finalPredicate
        )
    }
    
    var body: some View {
        if(chat.type == "Room") {
            NavigationLink(destination: RoomView(room: client.getRoomById(roomId: Int(chat.chatId))).navigationBarTitle(chat.name ?? "<chat name couldn't be loaded>").environment(\.managedObjectContext, CoreDataModel.shared.persistentContainer.viewContext)) {
                HStack {
                    Image("Facebook")
                        .resizable()
                        .cornerRadius(360)
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 4)

                    if messages.count != 0 {
                        if messages[0].isRead {
                            VStack {
                                Text(chat.name ?? "<chat name couldn't be loaded>")
                                    .font(.callout)
                                    .foregroundColor(Color("CustomForegroundColor"))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if messages[0].isSystemNotification {
                                    Text("\(messages[0].message ?? "") • \(calendar.component(.hour, from: messages[0].date!)):\(calendar.component(.minute, from: messages[0].date!))")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(Color("CustomForegroundColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                   Text("\(messages[0].username ?? "") \(messages[0].message ?? "") • \(calendar.component(.hour, from: messages[0].date!)):\(calendar.component(.minute, from: messages[0].date!))")
                                        .font(.caption)
                                        .foregroundColor(Color("CustomForegroundColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        } else {
                            VStack {
                                Text(chat.name ?? "<chat name couldn't be loaded>")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(Color("CustomForegroundColor"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                               
                                if messages[0].isSystemNotification {
                                    Text("\(messages[0].message ?? "") • \(calendar.component(.hour, from: messages[0].date!)):\(calendar.component(.minute, from: messages[0].date!))")
                                        .bold()
                                        .font(.caption)
                                        .foregroundColor(Color("CustomForegroundColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else{
                                    Text("\(messages[0].username ?? ""): \(messages[0].message ?? "") • \(calendar.component(.hour, from: messages[0].date!)):\(calendar.component(.minute, from: messages[0].date!))")
                                        .bold()
                                        .font(.caption)
                                        .foregroundColor(Color("CustomForegroundColor"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }.font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(20)
                    .shadow(color: Color("ShadowColor"), radius: 5)
            }.padding(.vertical, 4)
                .padding(.horizontal, 12)
        } else {
            NavigationLink(destination: DMView(receiver: client.chatToUser(chat: chat)).navigationBarTitle(chat.name ?? "<username id couldn't be loaded>").environment(\.managedObjectContext, CoreDataModel.shared.persistentContainer.viewContext)) {
                HStack {
                    Image("Facebook")
                        .resizable()
                        .cornerRadius(360)
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 4)
                   
                    if dms[0].isRead {
                        VStack {
                            Text(chat.name ?? "<username id couldn't be loaded>")
                                .font(.callout)
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(dms[0].username ?? ""): \(dms[0].message ?? "") • \(calendar.component(.hour, from: dms[0].date!)):\(calendar.component(.minute, from: dms[0].date!))")
                                .font(.caption)
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        VStack {
                            Text(chat.name ?? "<username id couldn't be loaded>")
                                .font(.callout)
                                .bold()
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(dms[0].username ?? ""): \(dms[0].message ?? "") • \(calendar.component(.hour, from: dms[0].date!)):\(calendar.component(.minute, from: dms[0].date!))")
                                .bold()
                                .font(.caption)
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }.font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(20)
                    .shadow(color: Color("ShadowColor"), radius: 5)
            }.padding(.vertical, 4)
                .padding(.horizontal, 12)
        }
    }
}


struct ChatsView: View {
    
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    //@StateObject var messages: [DM] = []
   
    private var fetchRequest: FetchRequest<Chat>
    private var chats: FetchedResults<Chat> { fetchRequest.wrappedValue }
    @State private var searchResults: [User] = []
    @State private var selectedView = "Chats"
    @State private var userPickerSelection = ""
    
    @State var searchText = ""
    @State private var isSearchBarEditing = false
    
    var calendar = Calendar.current
    
    let views = ["Chats", "Friends"]
    
    init() {
        let userId = SocialifyClient.shared.getCurrentAccount()
        
//        let request: FetchRequest<Chat> = Chat.fetchRequest()
//        request.sortDescriptors = [
//            NSSortDescriptor(
//                keyPath: \Chat.id,
//                ascending: true)
//        ]
//        request.predicate = NSPredicate(format: "userId == %@", userId as! CVarArg)
//
//        fetchRequest = FetchRequest<Chat>(fetchRequest: request)

        self.fetchRequest = FetchRequest(
            entity: Chat.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Chat.id,
                    ascending: true)
            ]//,
            //predicate: NSPredicate(format: "userId == %@", userId as CVarArg)
        )
        
        print("=====================================")
        for chat in chats {
            print("dupa")
            print(chat)
        }
        print("=====================================")
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search ...", text: $searchText)
                .onChange(of: searchText) { value in
                    if(value != "") {
                        SocketIOManager.sharedInstance.findUser(phrase: searchText)
                    }
                }
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(14)
                .padding(.vertical, 8)
                .shadow(color: Color("ShadowColor"), radius: 5)
                .onTapGesture {
                    self.isSearchBarEditing = true
                }
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isSearchBarEditing {
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
            
            if isSearchBarEditing {
                Button(action: {
                    self.isSearchBarEditing = false
                    self.searchText = ""
                    
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, -4)
    }
    
    private var searchView: some View {
        ForEach(searchResults, id: \.self) { user in
            HStack {
                HStack {
                    NavigationLink(destination: DMView(receiver: user).navigationBarTitle(user.username ?? "<username couldn't be loaded>")) {
                        //                        Image(uiImage: UIImage(data: Data(base64Encoded: user.avatar!)!)!)
                        //                            .resizable()
                        //                            .aspectRatio(contentMode: .fit)
                        //                            .frame(height: 40)
                        //                            .clipShape(Circle())
                        
                        Text(user.username ?? "<username can't be loaded>")
                        
                        Spacer()
                    }
                    
                    let cardImage = Image(uiImage: UIImage(systemName: "person.fill.badge.plus")!)
                        .renderingMode(.template)
                    
                    Button("\(cardImage)") {
                        client.sendFriendRequest(id: user.id)
                    }.padding(.trailing, 5)
                }.font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(20)
                    .shadow(color: Color("ShadowColor"), radius: 5)
            }.padding(.horizontal)
                .foregroundColor(Color("CustomForegroundColor"))
        }
    }
    
    
    
    private var chatsView: some View {
        VStack {
            searchBar
            
            ScrollView {
                if isSearchBarEditing {
                    searchView
                } else {
                    ScrollView {
                        ForEach(Array(chats.enumerated()), id: \.element) { index, chat in
                            ChatTileView(chat: chat)
                            //Text("\(chat)")
                            //Text(String("\(client.fetchLastLiveMessageForRoom(roomId: Int(chat.chatId)).count==0)"))
                            //Text(String("\(client.fetchLastLiveMessageForRoom(roomId: Int(chat.chatId)))"))
                        }.onAppear {
                            print("======================")
                            print(chats)
                            print("======================")
                        }
                    }
                }
            }
        }
        
    }
    private var friendsView: some View {
        VStack {
            searchBar
            
            ScrollView {
                if !isSearchBarEditing {
                    HStack {
                        VStack {
                            Text("Siemanko")
                        }
                    }.padding(.horizontal)
                } else {
                    searchView
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Picker("Views", selection: $selectedView) {
                    ForEach(views, id: \.self) {
                        Text($0)
                    }
                }
            }.pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)
            
            if(selectedView == "Chats") {
                chatsView
                    .onAppear {
                        
                    }
            } else {
                friendsView
                    .onAppear {}
            }
        }
        .navigationBarTitle("Chats", displayMode: .inline)
        //.background(Color("BackgroundColor"))
        .onAppear {
            
            SocketIOManager.sharedInstance.getFindUserResponse { result in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.searchResults = result
                })
            }
            
            //SocketIOManager.sharedInstance.getFetchLastUnreadDMsResponse()
            SocketIOManager.sharedInstance.fetchLastUnreadDMs()
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}

// MARK: -------------------------------------------------Te kółka z tymi profilami-----------------------------------------------

//VStack {
//    HStack {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                ForEach(lastDMs, id: \.self) { dm in
//                    NavigationLink(destination: DMView(receiver: client.lastDMtoUser(dm: dm)).navigationBarTitle(dm.username ?? "<username couldn't be loaded>")) {
//                        VStack {
//                            if(dm.avatar != nil) {
//                                Image(uiImage: UIImage(data: Data(base64Encoded: dm.avatar!)!)!)
//                                    .resizable()
//                                    .cornerRadius(360)
//                                    .frame(width: 55, height: 55)
//                                    .shadow(color: Color("ShadowColor"), radius: 5)
//                                    .clipShape(Circle())
//                            } else {
//                                Image(systemName: "person.circle.fill")
//                                    .resizable()
//                                    .cornerRadius(360)
//                                    .frame(width: 45, height: 45)
//                                    .shadow(color: Color("ShadowColor"), radius: 5)
//                                    .clipShape(Circle())
//                            }
//
//                            Text(dm.username ?? "<username couldn't be loaded>")
//                                .font(.caption)
//                        }.foregroundColor(Color("CustomForegroundColor"))
//
//                    }
//                }
//            }.padding(.vertical)
//            .frame(maxWidth: 50)
//            .padding(.leading, 40)
//        }
//
//        if (self.lastDMs.count == 0) {
//            HStack{
//                Spacer()
//            }
//        }
//    }
//}.padding(.vertical, -8)
