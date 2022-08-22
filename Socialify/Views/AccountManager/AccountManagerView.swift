//
//  AccountManagerView.swift
//  Socialify
//
//  Created by Tomasz on 28/06/2021.
//

import SwiftUI
import SocialifySdk

struct AccountManagerView: View {
    
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isLogged") private var isLogged: Bool = true
    
    @State private var showLoginModal = false
    @State private var accounts: [Account] = []
    
    var body: some View {
        VStack {
            if(isLogged && accounts != []) {
                HStack {
                    Text("Current account")
                        .font(.headline)
                        .padding(.leading, 3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }.padding(.vertical, 2)
                
                ForEach(accounts, id: \.self) { account in
                    if(account.isCurrentAccount) {
                        AccountTileView(account: account)
                            .padding(.bottom)
                    }
                }
                
                HStack {
                    Text("Your accounts")
                        .font(.headline)
                        .padding(.leading, 3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }.padding(.top, 2)
                .padding(.bottom, -16)
                
                ScrollView {
                    ForEach(accounts, id: \.self) { account in
                        if(!account.isCurrentAccount) {
                            AccountTileView(account: account)
                                .padding(.vertical, 2)
                        }
                    }.padding()
                }.padding(.horizontal, -20)
                
                Spacer()
                
            } else {
                Spacer()
                HStack {
                    Spacer()
                    Text("account_manager.no_accounts")
                    Spacer()
                }
                Spacer()
            }
        }.navigationBarTitle("Accounts")
        .padding()
        //.background(Color("BackgroundColor"))
        .background(Color("BackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showLoginModal = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showLoginModal, onDismiss: { self.accounts = client.fetchAccounts() }) {
            NavigationView {
                LoginView()
                    .navigationBarTitle(Text("Back"))
                    .navigationBarHidden(true)
                    //.background(Color("BackgroundColor")).edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            self.accounts = client.fetchAccounts()
            Global.tabBar!.isHidden = true
        }
//        .onDisappear() {
//            Global.tabBar!.isHidden = false
//        }
    }
}

//struct AccountManagerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountManagerView()
//    }
//}
