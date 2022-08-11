//
//  GroupDetailsView.swift
//  Socialify
//
//  Created by Tomasz on 05/07/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct GroupDetailsView: View {
    let group: ChatGroup
    var body: some View {
        VStack {
            VStack {
            VStack {
                ZStack {
                    Image(systemName: "person.circle.fill")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 92)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 150)
                        .zIndex(2)
                        //.shadow(color: Color("ShadowColor"), radius: 20)

                    VStack {
                        Text(group.name ?? "<name can't be loaded>")
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 70)

                        Text("2115 members")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Divider()
                            .padding()

                        Text(group.groupDescription ?? "")
                            .padding(.bottom, 20)

                    }.background(Color("CustomAppearanceItemColor"))
                    .zIndex(1)
                    .cornerRadius(12)
                    .padding(.top, 50)
                    //.shadow(color: Color("ShadowColor"), radius: 5)

                }.padding(.horizontal)
                //.padding(.top, 20)
                    .padding(.bottom)

//                HStack {
//                    VStack(alignment: HorizontalAlignment.center) {
//                        Image(systemName: "phone.fill")
//                            .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 20)
//                            .padding(.top)
//                            .padding(.horizontal, 11)
//
//                        Text("Call")
//                            .font(.headline)
//                            .padding(.horizontal, 34)
//                            .padding(.bottom)
//
//                    }.background(Color("CustomAppearanceItemColor"))
//                    .cornerRadius(12)
//                    .padding(.vertical)
//                    .padding(.horizontal, 4)
//                    //.shadow(color: Color("ShadowColor"), radius: 5)
//
//                    VStack(alignment: HorizontalAlignment.center) {
//                        Image(systemName: "video.fill")
//                            .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 20)
//                            .padding(.top)
//                            .padding(.horizontal, 11)
//
//                        Text("Video")
//                            .font(.headline)
//                            .padding(.horizontal, 34)
//                            .padding(.bottom)
//
//                    }.background(Color("CustomAppearanceItemColor"))
//                    .cornerRadius(12)
//                    .padding(.vertical)
//                    .padding(.horizontal, 4)
//                    //.shadow(color: Color("ShadowColor"), radius: 5)
//
//                    VStack(alignment: HorizontalAlignment.center) {
//                        Image(systemName: "bell.slash.fill")
//                            .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 20)
//                            .padding(.top)
//                            .padding(.horizontal, 11)
//
//                        Text("Mute")
//                            .font(.headline)
//                            .padding(.horizontal, 34)
//                            .padding(.bottom)
//
//                    }.background(Color("CustomAppearanceItemColor"))
//                    .cornerRadius(12)
//                    .padding(.vertical)
//                    .padding(.horizontal, 4)
//                    //.shadow(color: Color("ShadowColor"), radius: 5)
//                }.padding(.bottom, -10)
//                    .zIndex(2)

                
                
//                VStack {
//                    HStack {
//                        Text("Settings")
//                            .font(.system(size: 26))
//                            .fontWeight(.semibold)
//                            .multilineTextAlignment(.leading)
//
//                        Spacer()
//                    }.padding()
//
//                    Button(action: {}) {
//                        HStack {
//                            Image(systemName: "wallet.pass.fill")
//                                .renderingMode(.template)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(height: 22)
//                                .padding(.leading, 24)
//
//                            Text("Room ID")
//                                .padding(.leading, 12)
//
//                            Spacer()
//
//                            Text("\(group.id!)")
//                                .padding(.trailing, 20)
//                                .foregroundColor(.secondary)
//                        }
//                    }.foregroundColor(Color("CustomForegroundColor"))
//
//                    Divider()
//                        .padding(8)
//
//                    NavigationLink(destination: AddGroupMembersView(group: group)) {
//                        HStack {
//                            Image(systemName: "link.badge.plus")
//                                .renderingMode(.template)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(height: 24)
//                                .padding(.leading, 20)
//
//                            Text("Add members")
//                                .padding(.leading, 7)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .padding(.trailing, 20)
//                                .foregroundColor(.accentColor)
//                        }
//                    }.foregroundColor(Color("CustomForegroundColor"))
//
//                    Divider()
//                        .padding(8)
//
//                    NavigationLink(destination: GroupMembersView()) {
//                        HStack {
//                            Image(systemName: "person.2.fill")
//                                .renderingMode(.template)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(height: 18)
//                                .padding(.leading, 19)
//
//                            Text("Room members")
//                                .padding(.leading, 7)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .padding(.trailing, 20)
//                                .foregroundColor(.accentColor)
//                        }
//                    }.foregroundColor(Color("CustomForegroundColor"))
//                    .padding(.bottom, 20)
//                }.background(Color("CustomAppearanceItemColor"))
//                    .cornerRadius(12)
//                    .padding()
                }
            }
            Form {
                Section(header: Text("Settings")) {
                        NavigationLink(destination: AddGroupMembersView(group: group)) {
                            Label("Add members", systemImage: "link.badge.plus")
                                .accessibility(label: Text("Add members"))
                        }
                        
                    NavigationLink(destination: GroupMembersView(group: group)) {
                            Label("Group members", systemImage: "person.2.fill")
                                .accessibility(label: Text("Group members"))
                        }
                    
                    NavigationLink(destination: RoomsEditView(group: group)) {
                            Label("Rooms", systemImage: "text.bubble.fill")
                                .accessibility(label: Text("Rooms"))
                        }
                    }
                }.background(Color("BackgroundForm"))
        }.onAppear {
            Global.tabBar!.isHidden = true
        }.background(Color("BackgroundForm"))
//        .onDisappear {
//            Global.tabBar!.isHidden = false
//        }
    }
}
//
//struct GroupDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupDetailsView()
//    }
//}
