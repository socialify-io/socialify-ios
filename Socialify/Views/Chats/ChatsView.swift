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
    
    var body: some View {
        if(chat.type == "Room") {
            NavigationLink(destination: RoomView(room: client.getRoomById(roomId: Int(chat.chatId))).navigationBarTitle(chat.name ?? "<chat name couldn't be loaded>").environment(\.managedObjectContext, CoreDataModel.shared.persistentContainer.viewContext)) {
                HStack {
                    Image("Facebook")
                        .resizable()
                        .cornerRadius(360)
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 4)
                    
                    if chat.isRead {
                        VStack {
                            Text(chat.name ?? "<chat name couldn't be loaded>")
                                .font(.callout)
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if chat.lastMessageAuthor == nil {
                                Text("\(chat.lastMessageAuthor ?? "") \(chat.lastMessage ?? "") • \(calendar.component(.hour, from: chat.date!)):\(calendar.component(.minute, from: chat.date!))")
                                    .font(.caption)
                                    .foregroundColor(Color("CustomForegroundColor"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("\(chat.lastMessageAuthor ?? ""): \(chat.lastMessage ?? "") • \(calendar.component(.hour, from: chat.date!)):\(calendar.component(.minute, from: chat.date!))")
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
                            
                            Text("\(chat.lastMessageAuthor ?? ""): \(chat.lastMessage ?? "") • \(calendar.component(.hour, from: chat.date!)):\(calendar.component(.minute, from: chat.date!))")
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
        } else {
            NavigationLink(destination: DMView(receiver: client.chatToUser(chat: chat)).navigationBarTitle(chat.name ?? "<username id couldn't be loaded>").environment(\.managedObjectContext, CoreDataModel.shared.persistentContainer.viewContext)) {
                HStack {
                    Image("Facebook")
                        .resizable()
                        .cornerRadius(360)
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 4)
                    
                    if chat.isRead {
                        VStack {
                            Text(chat.name ?? "<username id couldn't be loaded>")
                                .font(.callout)
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(chat.lastMessageAuthor ?? ""): \(chat.lastMessage ?? "") • \(calendar.component(.hour, from: chat.date!)):\(calendar.component(.minute, from: chat.date!))")
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
                            
                            Text("\(chat.lastMessageAuthor ?? ""): \(chat.lastMessage ?? "") • \(calendar.component(.hour, from: chat.date!)):\(calendar.component(.minute, from: chat.date!))")
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
    
    @State private var chats: [Chat] = []
    @State private var searchResults: [User] = []
    @State private var selectedView = "Chats"
    @State private var userPickerSelection = ""
    
    @State var searchText = ""
    @State private var isSearchBarEditing = false
    
    var calendar = Calendar.current
    
    let views = ["Chats", "Friends"]
    
    init() {
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
                        ForEach(chats, id: \.self) { chat in
                            ChatTileView(chat: chat)
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
            self.chats = client.fetchChats()
            
            print("============")
            print(chats)
            print("============")
            
            SocketIOManager.sharedInstance.getFindUserResponse { result in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.searchResults = result
                })
            }
            
            SocketIOManager.sharedInstance.getFetchLastUnreadDMsResponse()
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
