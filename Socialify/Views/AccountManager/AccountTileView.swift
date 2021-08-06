//
//  AccountTileView.swift
//  AccountTileView
//
//  Created by Tomasz on 05/08/2021.
//

import SwiftUI
import CoreData
import SocialifySdk

struct AccountTileView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @Environment(\.presentationMode) var presentationMode
    
    var account: Account
    
    var body: some View {
            HStack {
                Button(action: { client.setCurrentAccount(account: account)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    if(account.isCurrentAccount) {
                        ZStack {
                            Image("Facebook")
                                .resizable()
                                .cornerRadius(360)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 18))
                                .padding(.top, 30)
                                .padding(.leading, 26)
                        }
                    } else {
                        Image("Facebook")
                            .resizable()
                            .cornerRadius(360)
                            .frame(width: 40, height: 40)
                            .padding(2)
                            .padding(.trailing, 2)
                    }
                        
                    VStack {
                        Text(LocalizedStringKey(account.username ?? "<username can't be loaded>"))
                            .font(.callout)
                            .foregroundColor(Color("CustomForegroundColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("example@socialify.io")
                            .font(.caption)
                            .foregroundColor(Color("CustomForegroundColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                let cardImage = Image(uiImage: UIImage(systemName: "ellipsis")!)
                    .renderingMode(.template)
                    
                NavigationLink("\(cardImage)", destination: AccountCardView(account: account))
                    .foregroundColor(Color.accentColor)
                    .padding(.trailing, 8)

            }.font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color("CustomAppearanceItemColor"))
            .cornerRadius(20)
            .shadow(color: .black, radius: 5)
    }
}

//struct AccountCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountCardView(account: account)
//    }
//}
