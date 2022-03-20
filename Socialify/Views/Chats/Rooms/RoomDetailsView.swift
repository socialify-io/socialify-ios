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
                        .shadow(color: Color("ShadowColor"), radius: 20)
                    
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
                    .shadow(color: Color("ShadowColor"), radius: 5)
                    
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
                    .shadow(color: Color("ShadowColor"), radius: 5)
                    
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
                    .shadow(color: Color("ShadowColor"), radius: 5)
                    
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
                    .shadow(color: Color("ShadowColor"), radius: 5)
                }
                
                VStack {
                    HStack {
                        Image(systemName: "wallet.pass.fill")
                         .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .padding(.leading, 24)
                        
                        Text("Room ID")
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Text("\(room.roomId!)")
                            .bold()
                            .padding(.trailing, 20)
                            .foregroundColor(.secondary)
                    }.padding(.vertical)
                }.background(Color("CustomAppearanceItemColor"))
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: Color("ShadowColor"), radius: 5)
                
                Spacer()
            }
        }.onAppear {
            SocketIOManager.sharedInstance.getInfoAboutRoom(roomId: room.roomId as! Int) { response in
                switch(response) {
                case .success(let response):
                    self.details = response
                    
                case .failure(let error):
                    print("ERROR ŁEEEE")
                }
            }
        }
    }
}

//struct RoomDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomDetailsView()
//    }
//}
