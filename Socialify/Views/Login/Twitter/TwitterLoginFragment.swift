//
//  TwitterLoginFragment.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI
import TwitterSdk

struct TwitterLoginFragment: View {
    @State private var login = ""
    @State private var password = ""
    
    let cellHeight: CGFloat
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    var body: some View {
        VStack {
            TextField("tw_login.username", text: $login)
                .autocapitalization(.none)
                .font(Font.body.weight(Font.Weight.medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(height: cellHeight)
                .background(cellBackground)
                .cornerRadius(cornerRadius)
            
            SecureField("login.password", text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(Font.body.weight(Font.Weight.medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(height: cellHeight)
                .background(cellBackground)
                .cornerRadius(cornerRadius)
                
            Link("login.singup", destination: URL(string: "https://twitter.com/i/flow/signup")!)
                .foregroundColor(Color.accentColor)
                .padding()
        }.padding(.bottom)
        
        Spacer()
        Spacer()
        
        CustomButtonView(action: {
            let client = TwitterClient()
            client.login(email: login, password:password)
        }, title: "login.button")
    }
}

struct TwitterLoginFragment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TwitterLoginFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
        }
    }
}
