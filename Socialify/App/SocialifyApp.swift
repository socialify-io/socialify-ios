//
//  SocialifyApp.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI

@main
struct SocialifyApp: App {
    @AppStorage("isLogged") private var isLogged: Bool = true
    @AppStorage("needsAppOnboarding") private var needsAppOnboarding: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if(needsAppOnboarding == true) {
                OnboardingView()
            } else {
                if(isLogged == true) {
                    GeometryReader { geometry in
                        ZStack {
                            Image("Facebook")
                                .resizable()
                                .clipShape(Circle())
                                //.overlay(Circle().stroke(Color("CustomAppearanceItemColor"), lineWidth: 3))
                                .shadow(radius: 4)
                                .zIndex(2)
                                .offset(y: geometry.size.height/10*4.42)
                                .frame(width: geometry.size.width/6 , height: geometry.size.width/6)
                            
                            NavigationBarView()
                                .zIndex(1)
                        }
                    }
                } else {
                    NavigationView {
                        LoginView()
                            .navigationBarTitle(Text("Back"))
                            .navigationBarHidden(true)
                            .background(Color("BackgroundColor").ignoresSafeArea(.all))
                    }
                }
            }
        }
    }
}

