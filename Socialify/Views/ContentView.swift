//
//  ContentView.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack{
            ScrollView {
                FacebookItemView(icon: "Facebook")
                FacebookItemView(icon: "Facebook")
                FacebookItemView(icon: "Facebook")
                FacebookItemView(icon: "Facebook")
            }.padding()
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AccountManagerView()) {
                    Image(systemName: "person.circle")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .navigationBarTitle("Homepage", displayMode: .inline)
        .background(Color("BackgroundColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
