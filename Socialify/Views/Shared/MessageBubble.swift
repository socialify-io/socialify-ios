//
//  MessageBubble.swift
//  Socialify
//
//  Created by Tomasz on 05/05/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct LeftMessageBubble: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let message: Message
    let media: FetchedResults<Media>
    @State var groupData: [String: String] = [:]
    
    @State var lastScaleValue: CGFloat = 1.0
    @State var trailingPadding: CGFloat = 25
    @State var paddingIfGroupData: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    ForEach(media) { mediaElement in
                        if mediaElement.messageId as! String == message.id as! String {
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
                            VStack {
                                HStack {
                                    Text(message.message ?? "<message can't be loaded>")
                                        .font(.subheadline)
                                    //Spacer()
                                }.padding(.vertical, 12)
                                .padding(.horizontal)
                                .padding(.bottom, paddingIfGroupData)
                                
                                if (groupData != [:]) {
                                    VStack(alignment: .leading) {
//                                        HStack {
//                                            Text("You have been invited to")
//                                                .font(.caption)
//                                                .multilineTextAlignment(.leading)
//                                                .padding(.leading, 5)
//                                            Spacer()
//                                        }
                                        HStack {
                                            Image("Facebook")
                                                .resizable()
                                                .cornerRadius(20)
                                                .frame(width: 50, height: 50)
                                                .padding(.trailing, 4)

                                            VStack(alignment: .leading) {
                                                Text(groupData["name"] ?? "<name>")
                                                Text(groupData["description"] ?? "<description>")
                                                    .font(.footnote)
                                            }
                                        }
                                       
                                        Button(LocalizedStringKey("Join")) {
                                            SocketIOManager.sharedInstance.joinGroup(linkId: groupData["linkId"]!) { response in
                                               print(response)
                                            }
                                        }
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .frame(height: 40)
                                        .frame(maxWidth: .infinity)
                                        .background(Color("ButtonColor"))
                                        .cornerRadius(12)
                                    }
                                    .padding()
                                    .background(
                                        RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20)
                                            .fill(Color("ButtonColor"))
                                    )
                                }
                            }
                        }.background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                        Spacer()
                    }
                }
            }
        }.padding(.leading, 4)
            .padding(.vertical, -5)
            .padding(.trailing, trailingPadding)
            .onAppear() {
                SocketIOManager.sharedInstance.isInviteLinkInMessage(message: message.message ?? "<message can't be loaded>") { result in
                    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                    print(result)
                    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                    let success: Bool = result["success"] as! Bool
                    if (success) {
                        trailingPadding = 0
                        groupData = result["data"] as! [String: String]
                        paddingIfGroupData = -12
                    }
                }
            }
    }
}

struct RightMessageBubble: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let message: Message
    let media: FetchedResults<Media>
    @State var groupData: [String: String] = [:]
    
    @State var lastScaleValue: CGFloat = 1.0
    @State var trailingPadding: CGFloat = 25
    @State var paddingIfGroupData: CGFloat = 0
    
    var body: some View {
        HStack {
            Spacer()
                                    
            VStack {
                ForEach(media) { mediaElement in
                    if mediaElement.messageId as! String == message.id as! String {
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
                    VStack {
                        HStack {
                            HStack {
                                Text(message.message ?? "<message can't be loaded>")
                                    .font(.callout)
                                if (groupData != [:]) {
                                    Spacer()
                                }
                            }.padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(Color("CustomAppearanceItemColor"))
                            .cornerRadius(20)
                            .padding(.trailing, 5)
                            .padding(.bottom, paddingIfGroupData)
                        }
                        
                        if (groupData != [:]) {
                            VStack(alignment: .leading) {
//                                        HStack {
//                                            Text("You have been invited to")
//                                                .font(.caption)
//                                                .multilineTextAlignment(.leading)
//                                                .padding(.leading, 5)
//                                            Spacer()
//                                        }
                                HStack {
                                    Image("Facebook")
                                        .resizable()
                                        .cornerRadius(20)
                                        .frame(width: 50, height: 50)
                                        .padding(.trailing, 4)

                                    VStack(alignment: .leading) {
                                        Text(groupData["name"] ?? "<name>")
                                        Text(groupData["description"] ?? "<description>")
                                            .font(.footnote)
                                    }
                                }
                               
                                Button(LocalizedStringKey("Join")) {
                                    SocketIOManager.sharedInstance.joinGroup(linkId: groupData["linkId"]!) { response in
                                       print(response)
                                    }
                                }
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color("ButtonColor"))
                                .cornerRadius(12)
                            }
                            .padding()
                            .background(
                                RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20)
                                    .fill(Color("ButtonColor"))
                            )
                        }
                    }.background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.leading, 25)
        .onAppear {
            SocketIOManager.sharedInstance.isInviteLinkInMessage(message: message.message ?? "<message can't be loaded>") { result in
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                print(result)
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                let success: Bool = result["success"] as! Bool
                if (success) {
                    trailingPadding = 0
                    groupData = result["data"] as! [String: String]
                    paddingIfGroupData = -12
                }
            }
        }
    }
}

struct LeftDMBubble: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let message: DM
    let media: FetchedResults<Media>
    @State var groupData: [String: String] = [:]
    
    @State var lastScaleValue: CGFloat = 1.0
    @State var trailingPadding: CGFloat = 25
    @State var paddingIfGroupData: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    ForEach(media) { mediaElement in
                        if mediaElement.messageId as! String == message.id as! String {
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
                            VStack {
                                HStack {
                                    Text(message.message ?? "<message can't be loaded>")
                                        .font(.subheadline)
                                    if(groupData != [:]) {
                                        Spacer()
                                    }
                                }.padding(.vertical, 12)
                                .padding(.horizontal)
                                .padding(.bottom, paddingIfGroupData)
                                
                                if (groupData != [:]) {
                                    VStack(alignment: .leading) {
//                                        HStack {
//                                            Text("You have been invited to")
//                                                .font(.caption)
//                                                .multilineTextAlignment(.leading)
//                                                .padding(.leading, 5)
//                                            Spacer()
//                                        }
                                        HStack {
                                            Image("Facebook")
                                                .resizable()
                                                .cornerRadius(20)
                                                .frame(width: 50, height: 50)
                                                .padding(.trailing, 4)

                                            VStack(alignment: .leading) {
                                                Text(groupData["name"] ?? "<name>")
                                                Text(groupData["description"] ?? "<description>")
                                                    .font(.footnote)
                                            }
                                        }
                                       
                                        Button(LocalizedStringKey("Join")) {
                                            SocketIOManager.sharedInstance.joinGroup(linkId: groupData["linkId"]!) { response in
                                               print(response)
                                            }
                                        }
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .frame(height: 40)
                                        .frame(maxWidth: .infinity)
                                        .background(Color("ButtonColor"))
                                        .cornerRadius(12)
                                    }
                                    .padding()
                                    .background(
                                        RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20)
                                            .fill(Color("ButtonColor"))
                                    )
                                }
                            }
                        }.background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                        Spacer()
                    }
                }
            }
        }.padding(.leading, 4)
            .padding(.vertical, -5)
            .padding(.trailing, trailingPadding)
            .onAppear() {
                SocketIOManager.sharedInstance.isInviteLinkInMessage(message: message.message ?? "<message can't be loaded>") { result in
                    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                    print(result)
                    print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                    let success: Bool = result["success"] as! Bool
                    if (success) {
                        trailingPadding = 0
                        groupData = result["data"] as! [String: String]
                        paddingIfGroupData = -12
                    }
                }
            }
    }
}


struct RightDMBubble: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let message: DM
    let media: FetchedResults<Media>
    @State var groupData: [String: String] = [:]
    
    @State var lastScaleValue: CGFloat = 1.0
    @State var trailingPadding: CGFloat = 25
    @State var paddingIfGroupData: CGFloat = 0
    
    var body: some View {
        HStack {
            Spacer()
                                    
            VStack {
                ForEach(media) { mediaElement in
                    if mediaElement.messageId as! String == message.id as! String {
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
                    VStack {
                        HStack {
                            HStack {
                                Text(message.message ?? "<message can't be loaded>")
                                    .font(.callout)
                                if (groupData != [:]) {
                                    Spacer()
                                }
                            }.padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color("CustomAppearanceItemColor"))
                                .cornerRadius(20)
                            //.shadow(color: Color("ShadowColor"), radius: 5)
                                .padding(.trailing, 5)
                                .padding(.bottom, paddingIfGroupData)
                        }
                        
                        if (groupData != [:]) {
                            VStack(alignment: .leading) {
//                                        HStack {
//                                            Text("You have been invited to")
//                                                .font(.caption)
//                                                .multilineTextAlignment(.leading)
//                                                .padding(.leading, 5)
//                                            Spacer()
//                                        }
                                HStack {
                                    Image("Facebook")
                                        .resizable()
                                        .cornerRadius(20)
                                        .frame(width: 50, height: 50)
                                        .padding(.trailing, 4)

                                    VStack(alignment: .leading) {
                                        Text(groupData["name"] ?? "<name>")
                                        Text(groupData["description"] ?? "<description>")
                                            .font(.footnote)
                                    }
                                }
                               
                                Button(LocalizedStringKey("Join")) {
                                    SocketIOManager.sharedInstance.joinGroup(linkId: groupData["linkId"]!) { response in
                                       print(response)
                                    }
                                }
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color("ButtonColor"))
                                .cornerRadius(12)
                            }
                            .padding()
                            .background(
                                RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 20)
                                    .fill(Color("ButtonColor"))
                            )
                        }
                    }.background(Color("CustomAppearanceItemColor"))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.leading, 25)
        .onAppear {
            SocketIOManager.sharedInstance.isInviteLinkInMessage(message: message.message ?? "<message can't be loaded>") { result in
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                print(result)
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                let success: Bool = result["success"] as! Bool
                if (success) {
                    trailingPadding = 0
                    groupData = result["data"] as! [String: String]
                    paddingIfGroupData = -12
                }
            }
        }
    }
}

