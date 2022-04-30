//
//  RoomMembersView.swift
//  Socialify
//
//  Created by Tomasz on 18/04/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct RoomMembersView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let details: SocialifyClient.InfoAboutRoom?
    
    var body: some View {
        ScrollView {
//            Text(String(describing: "\(details)"))
            ForEach(details!.roomMembers) { member in
//                Text(String(describing:"\(member)"))
                RoomMemberTileView(member: member)
            }
        }
        .padding(.horizontal)
        .onAppear {
            print("-=-=--=-=-=-=-=-=-=-=-=-=")
            print(details)
            print("-=-=--=-=-=-=-=-=-=-=-=-=")
        }
        .background(Color("BackgroundColor"))
    }
}

struct RoomMemberTileView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let member: SocialifyClient.RoomMember
    
    var body: some View {
        HStack {
//           Text(String(describing: "\(member)"))
            Image("Facebook")
                .resizable()
                .cornerRadius(360)
                .frame(width: 40, height: 40)
                .padding(.trailing, 4)
    
            Text(member.username)
                .padding(.leading, 4)
                .font(.system(size: 20, weight: Font.Weight.bold))
            
            Spacer()
            Text(String(describing: member.role))
                .font(.callout)
                .foregroundColor(.secondary)
        }.font(.headline)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color("CustomAppearanceItemColor"))
        .cornerRadius(20)
        //.shadow(color: Color("ShadowColor"), radius: 5)
    }
}

//struct RoomMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomMembersView()
//    }
//}
