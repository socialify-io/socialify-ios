//
//  TabBarIcon.swift
//  Socialify
//
//  Created by Tomasz on 27/06/2021.
//

import SwiftUI

struct TabBarIcon: View {
     
     let width, height: CGFloat
     let systemIconName, tabName: String
     
     
     var body: some View {
         VStack {
             Image(systemName: systemIconName)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: width, height: height)
                 .padding(.top, 10)
             Text(tabName)
                 .font(.footnote)
             Spacer()
         }
     }
 }

struct TabBarIcon_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            TabBarIcon(width: geometry.size.width/5, height: geometry.size.height/28, systemIconName: "homekit", tabName: "Home")
        }
    }
}
