//
//  LoginView.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI

struct ChildLoginView: View {
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("LoginInput")
    
    @State private var login = ""
    @State private var password = ""
    
    @State private var buttonText = "login.button"
    
    var body: some View {
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
                
                Text("login.title")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
                Text("login.subtitle")
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
                
                NavigationLink("login.singup", destination: LoginView())
                    .foregroundColor(Color.accentColor)
                    .padding()
                
            }.padding(.bottom, 60)
            
            Spacer()
            Spacer()
            
            CustomButtonView(action: {
                print("Logging to Socialify...")
            }, title: buttonText)
            .padding(.bottom)
            
        }.padding()
    }
}

struct LoginView: View {
    var body: some View {
        ChildLoginView()
            .navigationBarTitle(Text(""), displayMode: .inline)
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
    }
}

struct LoginViewPreviews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
