//
//  AccountCardView.swift
//  AccountCardView
//
//  Created by Tomasz on 05/08/2021.
//

import SwiftUI
import CoreData
import SocialifySdk

struct AccountCardView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    var account: Account
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(LocalizedStringKey("Log out")) { client.deleteAccount(account: account) }
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.3))
                .cornerRadius(12)
                .foregroundColor(Color.red)
                .padding()
        }
    }
}

//struct AccountCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountCardView()
//    }
//}
