//
//  LoginWithOption.swift
//  Socialify
//
//  Created by Tomasz on 05/05/2021.
//

import Foundation
import SwiftUI

struct LoginWithOptionView: View {
    var action: () -> ()
    let image: String
    let title: String
    let cornerRadius: CGFloat
    let cellBackground: Color
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(image)
                    .resizable()
                    .cornerRadius(8)
                    .frame(width: 50, height: 50, alignment: .leading)
                    
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey(title))
                        .frame(alignment: .leading)
                    
                    Text("tt_login.another_way.verified_label")
                        .fontWeight(.semibold)
                        .padding(5)
                        .font(.caption)
                        .frame(height: 20)
                        .background(Color.green.opacity(0.3))
                        .foregroundColor(Color.green)
                        .cornerRadius(7)
                    
                    
                }.padding()
            }.padding(.leading, 50)
        }
        .font(.headline)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(7)
        .background(cellBackground)
        .cornerRadius(cornerRadius)
    }
}

/*struct LoginWithOptionView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(action: {
            print("Button tapped!")
        }, title: "Test")
            .previewLayout(.sizeThatFits)
    }
}
*/
