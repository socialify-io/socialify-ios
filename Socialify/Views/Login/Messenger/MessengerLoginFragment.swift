//
//  MessengerLoginFragment.swift
//  Socialify
//
//  Created by Tomasz on 12/05/2021.
//

import SwiftUI
import MessengerSdk

struct MessengerLoginFragment: View {
    @State private var login = ""
    @State private var password = ""
    
    let cellHeight: CGFloat
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    @State private var buttonText = "login.button"
    
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
            buttonText = "Logging in..."
            let client = MessengerClient()
            client.login(email: login, password: password) { value in
                switch value {
                case .success(let value):
                    buttonText = value
                    
                case .failure(let error):
                    print(error)
                    buttonText = "\(error)"
                }
            }
        }, title: buttonText)
        
    }
}

struct MessengerLoginFragment_Previews: PreviewProvider {
    static var previews: some View {
        MessengerLoginFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
    }
}
