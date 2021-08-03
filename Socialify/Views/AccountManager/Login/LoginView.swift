//
//  LoginView.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI
import SocialifySdk

struct LoginView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    let borderColor: Color = Color(UIColor.systemGray).opacity(0)
    
    @State private var clicked: Bool = false
    
    @State private var showAlert = false
    @State private var errorAlertShow: ErrorAlert?
    @State private var showErrorReportModal = false
    @State private var activeAlert: ActiveAlert = .success
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var buttonText = "login.button"
    
    private func setButton(textOnStart: String, textOnEnd: String) {
        withAnimation {
            buttonText = textOnStart
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    buttonText = textOnEnd
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Image("SocialifyIcon")
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
                TextField(LocalizedStringKey("login.username"), text: $username)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(setColor(input: username, clicked: clicked), lineWidth: 2)
                    )
                
                SecureField("login.password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(setColor(input: password, clicked: clicked), lineWidth: 2)
                    )
                
                NavigationLink("login.singup", destination: RegisterView())
                    .foregroundColor(Color.accentColor)
                    .padding()
                
            }.padding(.bottom, 60)
            
            Spacer()
            Spacer()
            
            CustomButtonView(action: {
                clicked = true
                client.registerDevice(username: username, password: password) { value in
                    switch(value) {
                    case .success(let value):
                        print(value)
                    
                    case .failure(let error):
                        print(error)
                    }
                }
            }, title: buttonText)
            .padding(.bottom)
            
        }.padding()
    }
}

struct LoginViewPreviews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
