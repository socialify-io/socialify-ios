//
//  MessageBubble.swift
//  Socialify
//
//  Created by Tomasz on 05/05/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct LeftDMBubble: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let message: DM
    let media: FetchedResults<Media>
    
    @State var lastScaleValue: CGFloat = 1.0
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    ForEach(media) { mediaElement in
                        if mediaElement.messageId as! Int64 == message.id {
                            let mediaurl: String = mediaElement.url!
                            HStack {
                                
                                let image: AsyncImage = AsyncImage(url: URL(string: "\(client.API_ROUTE)v\(client.API_VERSION)/getMedia/\(mediaurl)")!,
                                                                           placeholder: { Image(systemName: "circle.dashed") },
                                                                           image: { Image(uiImage: $0).resizable() })
                                
                                NavigationLink(destination: ChatImageView(syncedImage: image)) {
                                    HStack {
                                        image
                                            .scaledToFit()
                                            .cornerRadius(20)
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: 250, maxHeight: 250)
                                    .padding(.top, 7)
                                }
                            }
                        }
                    }
                    Spacer()
                }
               
                if(message.message != "") {
                    HStack {
                        HStack {
                            Text(message.message ?? "<message can't be loaded>")
                                    .font(.callout)
                            
                        }.padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                        Spacer()
                    }
                }
            }
        }.padding(.leading, 4)
            .padding(.vertical, -5)
    }
}


struct RightDMBubble: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let message: DM
    let media: FetchedResults<Media>
    
    @State var lastScaleValue: CGFloat = 1.0    
    var body: some View {
        HStack {
            Spacer()
                                    
            VStack {
                ForEach(media) { mediaElement in
                    if mediaElement.messageId as! Int64 == message.id {
                        let mediaurl: String = mediaElement.url!
                        HStack {
                            Spacer()
                            
                            let image: AsyncImage = AsyncImage(url: URL(string: "\(client.API_ROUTE)v\(client.API_VERSION)/getMedia/\(mediaurl)")!,
                                                                           placeholder: { Image(systemName: "circle.dashed") },
                                                               image: { Image(uiImage: $0).resizable() })
                                
                                NavigationLink(destination: ChatImageView(syncedImage: image)) {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        image
                                            .scaledToFit()
                                            .cornerRadius(20)
                                    }
                                    .frame(maxWidth: 250, maxHeight: 250)
                                }
                        }
                    }
                }
              
                if(message.message != "") {
                    HStack {
                        Spacer()
                        HStack {
                            Text(message.message ?? "<message can't be loaded>")
                                .font(.callout)
                        }.padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                        //.shadow(color: Color("ShadowColor"), radius: 5)
                        .padding(.trailing, 5)
                    }
                }
            }
        }.onAppear {
            print("MEDIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
            print(media)
            print("MEDIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        }
    }
}

