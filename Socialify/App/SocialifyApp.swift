//
//  SocialifyApp.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI
import SocialifySdk

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
                        .onAppear {
                            SocketIOManager.sharedInstance.connect()
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

