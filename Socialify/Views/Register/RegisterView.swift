//
//  RegisterView.swift
//  Socialify
//
//  Created by Tomasz on 27/07/2021.
//

import SwiftUI
import SocialifySdk

struct ErrorAlert: Identifiable {
    var id: String { name }
    let name: String
    let errorName: String
    let errorDescription: String
}

struct RegisterView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    
    @State private var username = ""
    @State private var password = ""
    @State private var repeatedPassword = ""
    
    @State public var buttonText = "register.title"
    @State private var clicked: Bool = false
    
    @State private var errorAlertShow: ErrorAlert?
    
    public func setButton(textOnStart: String, textOnEnd: String) {
        withAnimation {
            buttonText = textOnStart
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    buttonText = textOnEnd
                }
            }
        }
    }

    private func setColor(input: String) -> Color {
        if(clicked == true){
            switch(input) {
            case "username":
                if (username == "") { return Color.red.opacity(0.4) }
                else { return cellBackground }
                    
            case "password":
                if (password == "") { return Color.red.opacity(0.4) }
                else { return cellBackground }
            
            case "repeatedPassword":
                if (repeatedPassword == "") { return Color.red.opacity(0.4) }
                else { return cellBackground }
           
                
            default:
                return cellBackground
            }
        } else {
            return cellBackground
        }
    }
    
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
                                .stroke(setColor(input: "username"), lineWidth: 2)
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
                                .stroke(setColor(input: "password"), lineWidth: 2)
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
                                .stroke(setColor(input: "repeatedPassword"), lineWidth: 2)
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
                                buttonText = "Success!"
                                
                            case .failure(let error):
                                switch error {
                                    case SocialifyClient.ApiError.InvalidRepeatPassword:
                                        setButton(textOnStart: "Passwords are not same", textOnEnd: "register.title")
                                            
                                    case SocialifyClient.ApiError.InvalidUsername:
                                        setButton(textOnStart: "Username is already taken", textOnEnd: "register.title")
                                    
                                    default:
                                        errorAlertShow = ErrorAlert(name: "Something is wrong...", errorName: "\(error)", errorDescription: "Some error description bla bla bla...")
                                }
                            }
                        }
                    }
                }, title: buttonText)
                .padding(.bottom)
            }.padding()
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor")).edgesIgnoringSafeArea(.vertical)
        .alert(item: $errorAlertShow) { error in
            Alert(title: Text(error.name), message: Text("\(error.errorName): \(error.errorDescription)"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Report")) { print("Reporting a problem...") } )
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
