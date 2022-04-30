//
//  RoomDetailsView.swift
//  Socialify
//
//  Created by Tomasz on 16/03/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct RoomDetailsView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var currentAccount: Account?
    
    @State private var details: SocialifyClient.InfoAboutRoom?
    let room: Room
    
    var body: some View {
        ScrollView {
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
                        Text(room.name ?? "<name can't be loaded>")
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
                        
                        Text("rooooom super special description")
                            .padding(.bottom, 20)
                        
                    }.background(Color("CustomAppearanceItemColor"))
                    .zIndex(1)
                    .cornerRadius(12)
                    .padding(.top, 50)
                    //.shadow(color: Color("ShadowColor"), radius: 5)
                    
                }.padding(.horizontal)
                .padding(.top, 20)
               
                HStack {
                    VStack(alignment: HorizontalAlignment.center) {
                        Image(systemName: "phone.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.top)
                            .padding(.horizontal, 11)
                        
                        Text("Call")
                            .font(.headline)
                            .padding(.horizontal, 34)
                            .padding(.bottom)
                        
                    }.background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(12)
                    .padding(.vertical)
                    .padding(.horizontal, 4)
                    //.shadow(color: Color("ShadowColor"), radius: 5)
                    
                    VStack(alignment: HorizontalAlignment.center) {
                        Image(systemName: "video.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.top)
                            .padding(.horizontal, 11)
                        
                        Text("Video")
                            .font(.headline)
                            .padding(.horizontal, 34)
                            .padding(.bottom)
                        
                    }.background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(12)
                    .padding(.vertical)
                    .padding(.horizontal, 4)
                    //.shadow(color: Color("ShadowColor"), radius: 5)
                    
                    VStack(alignment: HorizontalAlignment.center) {
                        Image(systemName: "bell.slash.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.top)
                            .padding(.horizontal, 11)
                        
                        Text("Mute")
                            .font(.headline)
                            .padding(.horizontal, 34)
                            .padding(.bottom)
                        
                    }.background(Color("CustomAppearanceItemColor"))
                    .cornerRadius(12)
                    .padding(.vertical)
                    .padding(.horizontal, 4)
                    //.shadow(color: Color("ShadowColor"), radius: 5)
                }.padding(.bottom, -10)
                    .zIndex(2)
                
//                VStack {
//                    HStack {
//                        Image(systemName: "wallet.pass.fill")
//                         .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 22)
//                            .padding(.leading, 24)
//
//                        Text("Room ID")
//                            .padding(.leading, 10)
//
//                        Spacer()
//
//                        Text("\(room.roomId!)")
//                            .bold()
//                            .padding(.trailing, 20)
//                            .foregroundColor(.secondary)
//                    }.padding(.vertical)
//
//                    NavigationLink(destination: RoomMembersView()) {
//                        Image(systemName: "person.2.fill")
//                         .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 22)
//                            .padding(.leading, 24)
//
//                        Text("Room members")
//                            .padding(.leading, 10)
//
//                        Spacer()
//
//                        Image(systemName: "chevron.right")
//                        .renderingMode(.template)
//                            .padding(.trailing, 20)
//                            .foregroundColor(.secondary)
//
//                    }.padding(.vertical)
//                }.background(Color("CustomAppearanceItemColor"))
//                .cornerRadius(12)
//                .padding(.horizontal)
//                .shadow(color: Color("ShadowColor"), radius: 5)
               
//                Form {
//                    Section {
//                        HStack {
////                            Image(systemName: "wallet.pass.fill")
////                             .renderingMode(.template)
////                                .resizable()
////                                .aspectRatio(contentMode: .fit)
////                                .frame(height: 22)
////                                .padding(.leading, 24)
////
////                            Text("Room ID")
////                                .padding(.leading, 10)
//
//                            Label("Room ID", systemImage: "wallet.pass.fill")
//                                .accessibility(label: Text("Room ID"))
//
//                            Spacer()
//
//                            Text("\(room.roomId!)")
//                                .bold()
//                                .foregroundColor(.secondary)
//                        }.padding(.vertical)
//
//                        NavigationLink(destination: RoomMembersView(details: details)) {
//                            Label("Room members", systemImage: "person.2.fill")
//                                .accessibility(label: Text("Room members"))
//                        }.padding(.vertical)
//
//                    }
//                }.padding(.top, -20)
//                    .zIndex(1)
                
                VStack {
                HStack {
                    Text("Settings")
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }.padding()
                    
                Button(action: {}) {
                    HStack {
                        Image(systemName: "wallet.pass.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .padding(.leading, 24)
                        
                        Text("Room ID")
                            .padding(.leading, 12)
                        
                        Spacer()
                        
                        Text("\(room.roomId!)")
                            .padding(.trailing, 20)
                            .foregroundColor(.secondary)
                    }
                }.foregroundColor(Color("CustomForegroundColor"))
                
                Divider()
                    .padding(8)
                
                NavigationLink(destination: RoomMembersView(details: details)) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 18)
                            .padding(.leading, 19)
                        
                        Text("Room members")
                            .padding(.leading, 7)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 20)
                            .foregroundColor(.accentColor)
                    }
                }.foregroundColor(Color("CustomForegroundColor"))
                .padding(.bottom, 20)
            }.background(Color("CustomAppearanceItemColor"))
                .cornerRadius(12)
                .padding()
            }
        }.onAppear {
            SocketIOManager.sharedInstance.getInfoAboutRoom(roomId: room.roomId as! Int) { response in
                switch(response) {
                case .success(let response):
                    self.details = response
                    print("DETAILSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS111111111111111111111111111")
                    print(details)
                    print("DETAILSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS111111111111111111111111111111")
                    
                case .failure(let error):
                    print("ERROR ŁEEEE")
                }
            }
        }
        .background(Color("BackgroundColor"))
    }
}

//struct RoomDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomDetailsView()
//    }
//}
