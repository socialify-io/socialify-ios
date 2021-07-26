//
//  AccountManagerView.swift
//  Socialify
//
//  Created by Tomasz on 28/06/2021.
//

import SwiftUI

struct AccountManagerView: View {
    
    @State private var showLoginModal = false
      
    private func addAccount() {
        self.showLoginModal = true
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("No accounts added")
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
                    }) {
                    NavigationView {
                        LoginView()
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
