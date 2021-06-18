//
//  TikTokLoginFragment.swift
//  Socialify
//
//  Created by Tomasz on 05/04/2021.
//

import Foundation
import SwiftUI

struct TikTokLoginFragment: View {
    @State private var login = ""
    @State private var password = ""
    
    let cellHeight: CGFloat
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    var body: some View {
        VStack {
            TextField("tt_login.username", text: $login)
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
            
            NavigationLink(destination: TikTokAnotherWayFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)) {
                HStack {
                    Image(systemName: "person.2")
                        .font(.system(size: 25.0))
                        
                    Text("tt_login.another_way")
                        .padding()
                }
            }
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(3)
            .background(cellBackground)
            .cornerRadius(cornerRadius)
                
            Link("login.singup", destination: URL(string: "https://www.tiktok.com/signup")!)
                .foregroundColor(Color.accentColor)
                .padding()
        }.padding(.bottom)
        
        Spacer()
        Spacer()
        
        
        CustomButtonView(action: {
            print("Dupa")
        }, title: "login.button")
    }
}

struct TikTokLoginFragment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TikTokLoginFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
        }
    }
}
