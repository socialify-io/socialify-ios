//
//  NavigationBarView.swift
//  Socialify
//
//  Created by Tomasz on 27/06/2021.
//

import SwiftUI

struct Global {
    static var tabBar : UITabBar?
}

extension UITabBar {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        Global.tabBar = self
        print("Tab Bar moved to superview")
    }
}

struct NavigationBarView: View {
    @State private var showLoginModal = false
    
    var body: some View {
        /*GeometryReader { geometry in
            VStack {
                Spacer()
                ContentView()
                Spacer()
                
                HStack {
                    TabBarIcon(width: geometry.size.width/6, height: geometry.size.height/28, systemIconName: "house", tabName: "Home")
                    TabBarIcon(width: geometry.size.width/6, height: geometry.size.height/28, systemIconName: "person.2", tabName: "Friends")
                    
                    ZStack {
                        Image("Facebook")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: geometry.size.width/6 , height: geometry.size.width/6)
                            .overlay(Circle().stroke(Color("CustomAppearanceItemColor"), lineWidth: 3))
                            .shadow(radius: 4)
                        
                     }.offset(y: -geometry.size.height/18)
                    
                    TabBarIcon(width: geometry.size.width/6, height: geometry.size.height/28, systemIconName: "cart", tabName: "Marketplace")
                    TabBarIcon(width: geometry.size.width/6, height: geometry.size.height/28, systemIconName: "ellipsis.circle", tabName: "More")
                 }.frame(width: geometry.size.width, height: geometry.size.height/8)
                .background(Color("CustomAppearanceItemColor").shadow(radius: 2))
                .padding(.bottom, 2)
                
            }.edgesIgnoringSafeArea(.bottom)*/
        
        
        
        ZStack {
            TabView() {
                NavigationView {
                    ChatsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: AccountManagerView()) {
                                Image(systemName: "person.circle")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: AddGroupView()) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.fill")
                        .accessibility(label: Text("Chats"))
                }
                
                NavigationView {
                    MoreView()
                        .toolbar {
                            
                        }
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                            .accessibility(label: Text("Settings"))
                }
            }
        }
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView()
    }
}
