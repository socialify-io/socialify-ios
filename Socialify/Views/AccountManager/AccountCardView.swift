//
//  AccountCardView.swift
//  AccountCardView
//
//  Created by Tomasz on 05/08/2021.
//

import SwiftUI
import CoreData
import SocialifySdk

struct AccountCardView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @State private var isLogOutAlertPresented = false
    
    var account: Account
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "person.circle.fill")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 92)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 150)
                    .zIndex(2)
                    .shadow(color: .black, radius: 20)
                
                VStack {
                    Text(account.username ?? "<username can't be loaded>")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    
                    Text("example@socialify.io")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding()
                    
                    Button("Change Email Address") {}
                    .padding(.bottom, 20)
                    
                }.background(Color("CustomAppearanceItemColor"))
                .zIndex(1)
                .cornerRadius(12)
                .padding(.top, 50)
                .shadow(color: .black, radius: 5)
                
            }.padding(.horizontal)
            .padding(.top, 20)
            
            VStack {
                HStack {
                    Text("Settings")
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }.padding()
                
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "person.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .padding(.leading, 24)
                        
                        Text("Change username")
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 20)
                            .foregroundColor(.accentColor)
                            
                    }
                    
                }.foregroundColor(Color("CustomForegroundColor"))
                
                Divider()
                    .padding(8)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .padding(.leading, 24)
                        
                        Text("Change password")
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 20)
                            .foregroundColor(.accentColor)
                    }
                }.foregroundColor(Color("CustomForegroundColor"))
                
                Divider()
                    .padding(8)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .padding(.leading, 24)
                        
                        Text("See logs")
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 20)
                            .foregroundColor(.accentColor)
                    }
                }.foregroundColor(Color("CustomForegroundColor"))
                
                Divider()
                    .padding(8)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .padding(.leading, 24)
                        
                        Text("Delete account")
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 20)
                            .foregroundColor(.accentColor)
                    }
                }.foregroundColor(Color.red)
                    .padding(.bottom, 15)
                
            }.background(Color("CustomAppearanceItemColor"))
                .cornerRadius(12)
                .padding()
                .shadow(color: .black, radius: 5)
            
            Button(LocalizedStringKey("Log out")) { isLogOutAlertPresented = true }
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(Color.red)
                .padding()
                .padding(.bottom)
                .shadow(color: .black, radius: 5)
            
        }.background(Color("BackgroundColor"))
        .frame(width: .infinity, height: .infinity)
        .alert(isPresented: $isLogOutAlertPresented) {
            Alert(title: Text("Log out"), message: Text("Do you want to log out from \(account.username ?? "<username can't be loaded>") account? All account data will be deleted from this device."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Log out")) { client.deleteAccount(account: account) } )
        }
    }
}

//struct AccountCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountCardView()
//    }
//}
