//
//  AccountManagerView.swift
//  Socialify
//
//  Created by Tomasz on 28/06/2021.
//

import SwiftUI

struct AccountManagerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showLoginModal = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("account_manager.no_accounts")
            Spacer()
        }
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
    }
}

struct AccountManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AccountManagerView()
    }
}
