//
//  LoginView.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI
import SocialifySdk
import UIKit

struct LoginView: View {
    @AppStorage("isLogged") private var isLogged: Bool = false
    
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @Environment(\.presentationMode) var presentationMode
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("CustomAppearanceItemColor")
    let borderColor: Color = Color(UIColor.systemGray).opacity(0)
    
    @State private var clicked: Bool = false

    @State private var errorAlertShow: ErrorAlert?
    @State private var showErrorReportModal = false
    
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
                        if(isLogged) {
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            isLogged = true
                            NavigationBarView()
                                .onAppear {
                                    SocketIOManager.sharedInstance.connect()
                                }
                        }

                    case .failure(let error):
                        switch error {
                        case SocialifyClient.ApiError.InvalidUsername:
                            setButton(textOnStart: "Invalid username", textOnEnd: "login.button")

                        case SocialifyClient.ApiError.InvalidPassword:
                            setButton(textOnStart: "Invalid password", textOnEnd: "login.button")

                        case SocialifyClient.SdkError.NoInternetConnection:
                            errorAlertShow = ErrorAlert(name: "errors.no_connection".localized, description: "errors.no_connection_description".localized)

                        default:
                            print(value)
                            errorAlertShow = ErrorAlert(name: "errors.default".localized, description: "errors.default_description".localized)
                        }
                    }
                }
            }, title: buttonText)
            .padding(.bottom)
        }.padding()
        .background(Color("BackgroundColor"))
        .sheet(isPresented: $showErrorReportModal, onDismiss: {
            }) {
            NavigationView {
                ErrorReportView(showErrorReportModal: self.$showErrorReportModal)
                    .navigationBarTitle(Text("Back"))
                    .navigationBarHidden(true)
                    //.background(Color("BackgroundColor")).edgesIgnoringSafeArea(.bottom)
            }
        }
        .alert(item: $errorAlertShow) { error in
        
            Alert(title: Text(errorAlertShow?.name ?? "errors.default"), message: Text(errorAlertShow?.description ?? "errors.default_description"), primaryButton: .cancel(), secondaryButton: .destructive(Text("errors.button")) { self.showErrorReportModal = true } )
        }
    }
}

struct LoginViewPreviews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
