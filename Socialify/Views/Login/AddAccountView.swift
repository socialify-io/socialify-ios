//
//  AddAccountView.swift
//  Socialify
//
//  Created by Tomasz on 30/03/2021.
//

import Foundation
import SwiftUI

struct AddAccountView: View {
    struct ChildAddAccountView: View {
        var body: some View {
            ScrollView {
                VStack {
                    Image("LaunchIcon")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .foregroundColor(.accentColor)
                    
                    Text("add_account.title")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(height: 100)
                    
                    VStack {
                        MediaItemView(destination: LoginView(icon: "Facebook"), title: "Facebook", icon: "Facebook")
                            .padding(.vertical, 3)
                        
                        MediaItemView(destination: LoginView(icon: "Messenger"), title: "Messenger", icon: "Messenger")
                            .padding(.vertical, 3)
                        
                        MediaItemView(destination: LoginView(icon: "Twitter"), title: "Twitter", icon: "Twitter")
                            .padding(.vertical, 3)
                        
                        MediaItemView(destination: LoginView(icon: "Instagram"), title: "Instagram", icon: "Instagram")
                            .padding(.vertical, 3)
                        
                        MediaItemView(destination: LoginView(icon: "TikTok"), title: "TikTok", icon: "TikTok")
                            .padding(.vertical, 3)
                        
                        MediaItemView(destination: LoginView(icon: "Pinterest"), title: "Pinterest", icon: "Pinterest")
                            .padding(.vertical, 3)
                    }
                    Spacer()
                }.padding()
            }
        }
    }
    
    var body: some View {
        ChildAddAccountView()
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView()
    }
}

