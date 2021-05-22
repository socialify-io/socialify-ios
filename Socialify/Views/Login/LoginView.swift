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
    
    var icon: String
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                HStack {
                    Image(icon)
                        .resizable()
                        .cornerRadius(8)
                        .frame(width: 60, height: 60)
                        .padding()
                    
                    Image(systemName: "link")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.accentColor)
                    
                    Image("ConnectionIcon")
                        .resizable()
                        .cornerRadius(8)
                        .frame(width: 60, height: 60)
                        .padding()
                }
                
                Text("login.title")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            switch(icon) {
            case "Facebook":
                FacebookLoginFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)
            case "Messenger":
                MessengerLoginFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)
            case "Twitter":
                TwitterLoginFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)
            case "Instagram":
                InstagramLoginFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)
            case "TikTok":
                TikTokLoginFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)
            case "Pinterest":
                PinterestLoginFragment(cellHeight: cellHeight, cornerRadius: cornerRadius, cellBackground: cellBackground)
            default:
                Text("Cuś nie pykło")
            }
        }.padding()
    }
}

struct LoginView: View {
    var icon: String
    
    var body: some View {
        ChildLoginView(icon: icon)
            .navigationBarTitle(Text(""), displayMode: .inline)
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
    }
}

struct LoginViewView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(icon: "Facebook")
    }
}
