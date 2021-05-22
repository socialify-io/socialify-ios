//
//  InstagramLoginFragment.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI

struct InstagramLoginFragment: View {
    @State private var login = ""
    @State private var password = ""
    
    let cellHeight: CGFloat
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    var body: some View {
        VStack {
            VStack {
                TextField("ig_login.username", text: $login)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                
                TextField("login.password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
            }.padding(.bottom)
            
            Divider()
            
            LoginWithOptionView(action: { print("Instagram - logging with facebook") },
                                image: "Facebook",
                                title: "login.facebook_login",
                                cornerRadius: cornerRadius,
                                cellBackground: cellBackground)
                .padding(2)
            
            Link("login.singup", destination: URL(string: "https://www.instagram.com/accounts/emailsignup/")!)
                .foregroundColor(Color.accentColor)
                .padding()
        }
        
        Spacer()
        
        CustomButtonView(action: {
            print("Dupa")
        }, title: "login.button")
    }
}

struct InstagramLoginFragment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstagramLoginFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
        }
    }
}
