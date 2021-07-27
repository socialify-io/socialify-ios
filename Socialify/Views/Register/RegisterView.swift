//
//  RegisterView.swift
//  Socialify
//
//  Created by Tomasz on 27/07/2021.
//

import SwiftUI
import UIKit

struct RegisterView: View {
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    
    @State private var login = ""
    @State private var password = ""
    @State private var repeatedPassword = ""
    
    @State private var buttonText = "register.title"
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                
                VStack {
                    Image("LaunchIcon")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 160)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, -40)
                    
                    Text("register.title")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 2)
                    
                    Text("register.subtitle")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                }.padding(.top, -40)
                
                Spacer()
                Spacer()
                
                VStack {
                    TextField("socialify_login.username", text: $login)
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
                    
                    SecureField("register.repeat_password", text: $repeatedPassword)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(Font.body.weight(Font.Weight.medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(height: cellHeight)
                        .background(cellBackground)
                        .cornerRadius(cornerRadius)
                    
                }.padding(.bottom, 80)
                
                Spacer()
                Spacer()
                
                CustomButtonView(action: {
                    print("Logging to Socialify...")
                }, title: buttonText)
                .padding(.bottom)
            }.padding()
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor")).edgesIgnoringSafeArea(.vertical)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
