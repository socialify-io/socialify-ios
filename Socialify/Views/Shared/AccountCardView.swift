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
    var account: Account
    
    var body: some View {
        NavigationLink(destination: AccountView()) {
            HStack {
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
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .renderingMode(.template)
                    .padding(.trailing, 8)
                
                Image(systemName: "trash")
                    .renderingMode(.template)
                    .foregroundColor(Color.red)

            }
        }
        .font(.headline)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("CustomAppearanceItemColor"))
        .cornerRadius(20)
    }
}

//struct AccountCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountCardView(account: account)
//    }
//}
