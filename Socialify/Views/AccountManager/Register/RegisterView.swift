//
//  RegisterView.swift
//  Socialify
//
//  Created by Tomasz on 27/07/2021.
//

import SwiftUI
import SocialifySdk

struct RegisterView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @Environment(\.presentationMode) var presentationMode
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    let borderColor: Color = Color(UIColor.systemGray).opacity(0)
    
    @State private var username = ""
    @State private var password = ""
    @State private var repeatedPassword = ""
    
    @State private var buttonText = "register.title"
    @State private var clicked: Bool = false
    
    @State private var showAlert = false
    @State private var errorAlertShow: ErrorAlert?
    @State private var showErrorReportModal = false
    @State private var activeAlert: ActiveAlert = .success
    
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
                    
                    SecureField("register.repeat_password", text: $repeatedPassword)
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
                                .stroke(setColor(input: repeatedPassword, clicked: clicked), lineWidth: 2)
                        )
                    
                }.padding(.bottom, 80)
                
                Spacer()
                Spacer()
                
                CustomButtonView(action: {
                    clicked = true
                    if(username != "" && password != "" && repeatedPassword != "" ) {
                        client.register(username: username, password: password, repeatedPassword: repeatedPassword) { value in
                            switch value {
                            case .success(_):
                                self.activeAlert = .success
                                self.showAlert = true
                                
                            case .failure(let error):
                                switch error {
                                    case SocialifyClient.ApiError.InvalidRepeatPassword:
                                        setButton(textOnStart: "login.different_passwords", textOnEnd: "register.title")
                                            
                                    case SocialifyClient.ApiError.InvalidUsername:
                                        setButton(textOnStart: "register.taken_username", textOnEnd: "register.title")
                                    
                                    case SocialifyClient.SdkError.NoInternetConnection:
                                    errorAlertShow = ErrorAlert(name: "errors.no_connection".localized, description: "errors.no_connection_description".localized)
                                        self.activeAlert = .failure
                                        self.showAlert = true
                                        
                                    default:
                                        print(value)
                                    errorAlertShow = ErrorAlert(name: "errors.default".localized, description: "errors.default_description".localized)
                                        self.activeAlert = .failure
                                        self.showAlert = true
                                }
                            }
                        }
                    }
                }, title: buttonText)
                .padding(.bottom)
            }.padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor")).edgesIgnoringSafeArea(.vertical)
        .sheet(isPresented: $showErrorReportModal, onDismiss: {
            }) {
            NavigationView {
                ErrorReportView(showErrorReportModal: self.$showErrorReportModal)
                    .navigationBarTitle(Text("Back"))
                    .navigationBarHidden(true)
                    .background(Color("BackgroundColor")).edgesIgnoringSafeArea(.bottom)
            }
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .success:
                return Alert(title: Text("success"), message: Text("register.success"), dismissButton: .default(Text("got_it")){
                                        DispatchQueue.main.async{
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    })
            case .failure:
                return Alert(title: Text(errorAlertShow?.name ?? "errors.default"), message: Text(errorAlertShow?.description ?? "errors.default_description"), primaryButton: .cancel(), secondaryButton: .destructive(Text("errors.button")) { self.showErrorReportModal = true } )
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
