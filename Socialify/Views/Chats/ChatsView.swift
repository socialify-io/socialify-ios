//
//  ChatsView.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI
import SocialifySdk
import CoreData

struct ChatsView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var chats: [Room] = []
    @State private var searchResults: [User] = []
    @State private var lastDMs: [LastDM] = []
    @State private var selectedView = ""
    
    @State var searchText = ""
     
    @State private var isSearchBarEditing = false
    
    var body: some View {
        VStack{
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
                    .cornerRadius(16)
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
            }.padding(.top)
            .padding(.horizontal)
            .padding(.bottom, -4)
            
            ScrollView {
                if !isSearchBarEditing {
                    VStack {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(lastDMs, id: \.self) { dm in
                                        VStack {
                                            if(dm.avatar != nil) {
                                                Image(uiImage: UIImage(data: Data(base64Encoded: dm.avatar!)!)!)
                                                    .resizable()
                                                    .cornerRadius(360)
                                                    .frame(width: 45, height: 45)
                                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .cornerRadius(360)
                                                    .frame(width: 45, height: 45)
                                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                                    .clipShape(Circle())
                                            }
                                            
                                            Text(dm.username ?? "<username couldn't be loaded>")
                                                .font(.caption)
                                        }
                                    }
                                }.padding(.vertical)
                            }
                        }.padding(.vertical, -8)
                        
                        VStack {
                            ForEach(chats, id: \.self) { chat in
                                NavigationLink(destination: ChatView(chat: chat).navigationBarTitle(chat.roomId ?? "<room id couldn't be loaded>")) {
                                    HStack {
                                        Image("Facebook")
                                            .resizable()
                                            .cornerRadius(360)
                                            .frame(width: 50, height: 50)
                                            .padding(.trailing, 4)
                                        
                                        VStack {
                                            Text(chat.roomId ?? "<room id couldn't be loaded>")
                                                .font(.callout)
                                                .foregroundColor(Color("CustomForegroundColor"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("Od kogo: Ostatnio wysłana wiadomość • 21:15")
                                                .font(.caption)
                                                .foregroundColor(Color("CustomForegroundColor"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
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
                            }
                        }
                    }.padding(.horizontal)
                } else {
                    ForEach(searchResults, id: \.self) { user in
                        NavigationLink(destination: DMView(receiver: user).navigationBarTitle(user.username ?? "<username couldn't be loaded>")) {
                            HStack {
                                Image(uiImage: UIImage(data: Data(base64Encoded: user.avatar!)!)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 40)
                                    .clipShape(Circle())
                                
                                Text(user.username ?? "<username can't be loaded>")
                                
                                Spacer()
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
            }
        }
        .navigationBarTitle("Chats", displayMode: .inline)
        .background(Color("BackgroundColor"))
        .onAppear {
            self.chats = client.fetchRooms()
            print("============")
            print(chats)
            print("============")
            self.lastDMs = SocketIOManager.sharedInstance.getLastDMs()
            
            SocketIOManager.sharedInstance.getFindUserResponse { result in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.searchResults = result
                })
            }
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
