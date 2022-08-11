//
//  GroupMembersView.swift
//  Socialify
//
//  Created by Tomasz on 05/07/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct GroupMemberTileView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared

    let member: SocialifyClient.GroupMember

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

            Spacer()
            Text(String(describing: member.role))
                .font(.callout)
                .foregroundColor(.secondary)
        }.font(.headline)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color("CustomAppearanceItemColor"))
        .cornerRadius(20)
        //.shadow(color: Color("ShadowColor"), radius: 5)
    }
}

struct GroupMembersView: View {
    let group: ChatGroup
    @State private var groupMembers: [SocialifyClient.GroupMember] = []
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(groupMembers) { member in
                    GroupMemberTileView(member: member)
                }
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .onAppear {
            SocketIOManager.sharedInstance.getGroupMembers(groupId: group.id!) { response in
                switch(response) {
                case .success(let resp):
                    groupMembers = resp
                case .failure(let error):
                    print("NIE DZIAŁA!!!")
                }
            }
        }
    }
}

//struct GroupMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupMembersView()
//    }
//}
