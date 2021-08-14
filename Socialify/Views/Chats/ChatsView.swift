//
//  ChatsView.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI
import SocialifySdk

struct ChatsView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var chats: [Room] = []
    @State private var selectedView = ""
    
    @State var searchText = ""
     
    @State private var isSearchBarEditing = false
    
    var body: some View {
        VStack{
            HStack {
                TextField("Search ...", text: $searchText)
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
                VStack {
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                    .padding(.leading, 8)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                Image("Facebook")
                                    .resizable()
                                    .cornerRadius(360)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
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
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: AccountManagerView()) {
                    Image(systemName: "person.circle")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NewRoomView()) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationBarTitle("Chats", displayMode: .inline)
        .background(Color("BackgroundColor"))
        .onAppear {
            chats = client.fetchRooms()
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
