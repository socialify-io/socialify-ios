//
//  TikTokAnotherWayFragment.swift
//  Socialify
//
//  Created by Tomasz on 05/05/2021.
//

import Foundation
import SwiftUI

struct TikTokAnotherWayFragment: View {
    
    let cellHeight: CGFloat
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image("TikTok")
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
            
            Spacer()
            
            ScrollView {
                LoginWithOptionView(action: { print("TikTok - logging with facebook") },
                                    image: "Facebook",
                                    title: "login.facebook_login",
                                    cornerRadius: cornerRadius,
                                    cellBackground: Color("CustomAppearanceItemColor"))
                    .padding(2)
                
                LoginWithOptionView(action: { print("TikTok - logging with Google") },
                                    image: "Google",
                                    title: "login.google_login",
                                    cornerRadius: cornerRadius,
                                    cellBackground: Color("CustomAppearanceItemColor"))
                    .padding(2)
                
                LoginWithOptionView(action: { print("TikTok - logging with twitter") },
                                    image: "Twitter",
                                    title: "login.twitter_login",
                                    cornerRadius: cornerRadius,
                                    cellBackground: Color("CustomAppearanceItemColor"))
                    .padding(2)
                
                LoginWithOptionView(action: { print("TikTok - logging with apple") },
                                    image: "Apple",
                                    title: "login.apple_login",
                                    cornerRadius: cornerRadius,
                                    cellBackground: Color("CustomAppearanceItemColor"))
                    .padding(2)
                
                LoginWithOptionView(action: { print("TikTok - logging with instagram") },
                                    image: "Instagram",
                                    title: "login.ig_login",
                                    cornerRadius: cornerRadius,
                                    cellBackground: Color("CustomAppearanceItemColor"))
                    .padding(2)
            }.padding(.horizontal)
            .frame(maxHeight: 500)
            Spacer()
        }
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
        
    }
}

struct TikTokAnotherWayFragment_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TikTokAnotherWayFragment(cellHeight: 55, cornerRadius: 12, cellBackground: Color("LoginInput"))
        }
    }
}
