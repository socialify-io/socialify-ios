//
//  PinterestLoginFragment.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI

struct PinterestLoginFragment: View {
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
            
            Divider()
            
            LoginWithOptionView(action: { print("Pinterest - logging with facebook") },
                                image: "Facebook",
                                title: "login.facebook_login",
                                cornerRadius: cornerRadius,
                                cellBackground: cellBackground)
                .padding(2)
            
            LoginWithOptionView(action: { print("Pinterest - logging with google") },
                                image: "Google",
                                title: "login.google_login",
                                cornerRadius: cornerRadius,
                                cellBackground: cellBackground)
                .padding(2)
            
            Link("login.singup", destination: URL(string: "https://pl.pinterest.com/signup/step1/")!)
                .foregroundColor(Color.accentColor)
                .padding()
        }
        
        Spacer()
        
        CustomButtonView(action: {
            print("Dupa")
        }, title: "login.button")
    }
}


struct PinterestLoginFragment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PinterestLoginFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
        }
    }
}
