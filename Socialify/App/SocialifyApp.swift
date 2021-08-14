//
//  SocialifyApp.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI

@main
@available(iOS 13.0, *)
struct SocialifyApp: App {
    @AppStorage("isLogged") private var isLogged: Bool = true
    @AppStorage("needsAppOnboarding") private var needsAppOnboarding: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if(needsAppOnboarding) {
                OnboardingView()
            } else {
                if(isLogged) {
                    NavigationBarView()
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

