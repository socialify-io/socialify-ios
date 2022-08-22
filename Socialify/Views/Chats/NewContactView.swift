//
//  NewContactView.swift
//  Socialify
//
//  Created by Tomasz on 16/08/2022.
//

import SwiftUI
import SocialifySdk
import CoreData

struct NewContactView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var searchText: String = ""
    @State private var isSearchBarEditing: Bool = false
    @State private var searchResult: User? = nil
    
    @State private var currentAccount: Account?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Username", text: $searchText)
//                    .onChange(of: searchText) { value in
//                        if(value != "") {
//                            SocketIOManager.sharedInstance.findUser(phrase: searchText)
//                        }
//                    }
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(14)
                    .padding(.vertical, 8)
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
                        
                        SocketIOManager.sharedInstance.searchForUser(phrase: searchText) { response in
                            switch(response) {
                            case .success(let user):
                                searchResult = user
                                
                            case .failure(_):
                                print("NIE DZIALAAAA")
                            }
                        }
                    }) {
                        Text("Search")
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
            
            if searchResult != nil {
                if searchResult?.id != currentAccount?.userId {
                    HStack {
                        NavigationLink(destination: DMView(receiver: searchResult!)) {
                            Image(uiImage: UIImage(data: searchResult!.avatar!)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            Text(searchResult!.username ?? "<username can't be loaded>")
                            
                            Spacer()
                        }
                        
                        let cardImage = Image(uiImage: UIImage(systemName: "person.fill.badge.plus")!)
                            .renderingMode(.template)
                        
                        Button("\(cardImage)") {
                            //client.sendFriendRequest(id: user.id)
                        }.padding(.trailing, 5)
                    }.font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                } else {
                    Text("You can't text to yourself :/")
                }
            } else {
                Text("There is no users with this username")
            }
            Spacer()
        }.padding()
        .background(Color("BackgroundColor"))
        .navigationBarTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New contact")
                    .bold()
            }
        }
        .onAppear {
            currentAccount = client.getCurrentAccount()
        }
    }
}

struct NewContactView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactView()
    }
}
