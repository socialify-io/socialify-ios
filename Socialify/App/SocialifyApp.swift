//
//  SocialifyApp.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI

@main
struct SocialifyApp: App {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @AppStorage("needsAppOnboarding") private var needsAppOnboarding: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if(needsAppOnboarding == true) {
                OnboardingView()
            } else {
                if(isLogged == true) {
                    NavigationView {
                        ContentView()
                            .navigationBarItems(trailing: NavigationLink(destination: OnboardingView()) {
                                Image(systemName: "person.circle")
                            })
                    }
                } else {
                    AddAccountView()
                }
            }
        }
    }
}

