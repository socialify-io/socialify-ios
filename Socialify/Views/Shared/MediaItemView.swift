//
//  MediaItemView.swift
//  Socialify
//
//  Created by Tomasz on 30/03/2021.
//

import Foundation
import SwiftUI
import CoreSpotlight
import CoreServices

struct MediaItemView<TargetView: View>: View {
    var destination: TargetView
    var title: String
    var icon: String
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(icon)
                    .resizable()
                    .cornerRadius(8)
                    .frame(width: 60, height: 60)
                    .padding()
                    
                VStack {
                    Text(LocalizedStringKey(title))
                        .foregroundColor(Color("CustomForegroundColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Lorem ipsum dolor sit amet.")
                        .font(.caption)
                        .foregroundColor(Color("CustomForegroundColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
        }
        .font(.headline)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("CustomAppearanceItemColor"))
        .cornerRadius(10)
    }
}

/*struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(action: {
            print("Button tapped!")
        }, title: "Test")
            .previewLayout(.sizeThatFits)
    }
}*/

