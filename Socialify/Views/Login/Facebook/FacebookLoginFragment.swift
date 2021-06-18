//
//  FacebookLoginFragment.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI
import FacebookSdk

struct FacebookLoginFragment: View {
    @State private var login = ""
    @State private var password = ""
    
    let cellHeight: CGFloat
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    var body: some View {
        VStack {
            TextField("fb_login.username", text: $login)
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
                
            Link("login.singup", destination: URL(string: "https://www.facebook.com/r.php")!)
                .foregroundColor(Color.accentColor)
                .padding()
        }.padding(.bottom)
        
        Spacer()
        Spacer()
        
        CustomButtonView(action: {
            let client = FacebookClient()
            client.login(email: login, password: password)
        }, title: "login.button")
        
    }
}

struct FacebookLoginFragment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FacebookLoginFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
        }
    }
}
