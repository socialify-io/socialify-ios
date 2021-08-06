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
            if(isLogged) {
                HStack {
                    Text("Current account")
                        .font(.headline)
                        .padding(.leading, 3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }.padding(.vertical, 2)
                
                ForEach(accounts, id: \.self) { account in
                    if(account.isCurrentAccount) {
                        AccountCardView(account: account)
                            .padding(.bottom)
                    }
                }
                
                HStack {
                    Text("Your accounts")
                        .font(.headline)
                        .padding(.leading, 3)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }.padding(2)
                
                ScrollView {
                    ForEach(accounts, id: \.self) { account in
                        if(!account.isCurrentAccount) {
                            AccountCardView(account: account)
                        }
                    }
                }
                
            } else {
                Spacer()
                Text("account_manager.no_accounts")
                Spacer()
            }
        }.navigationBarTitle("Accounts")
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showLoginModal = true }) {
                    Image(systemName: "plus")
                }
                .padding()
                .padding(.bottom, 16)
                .sheet(isPresented: $showLoginModal, onDismiss: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    NavigationView {
                        LoginView(showLoginModal: self.$showLoginModal)
                            .navigationBarTitle(Text("Back"))
                            .navigationBarHidden(true)
                            .background(Color("BackgroundColor")).edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
        }
        .onAppear {
            client.fetchAccounts() { response in
                switch(response) {
                case .success(let accounts) :
                    self.accounts = accounts
                    
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }
}

//struct AccountManagerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountManagerView()
//    }
//}
