//
//  CustomButtonView.swift
//  Socialify
//
//  Created by Tomasz on 30/03/2021.
//

import Foundation
import SwiftUI

struct CustomButtonView: View {
    var action: () -> ()
    var title: String
    
    var body: some View {
        Button(LocalizedStringKey(title)) { action() }
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding()
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color("ButtonColor"))
            .cornerRadius(12)
    }
}

struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(action: {
            print("Button tapped!")
        }, title: "Test")
            .previewLayout(.sizeThatFits)
    }
}
