//
//  GroupView.swift
//  Socialify
//
//  Created by Tomasz on 05/07/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

extension UserDefaults {

    func valueExists(forKey key: String) -> Bool {
        return object(forKey: key) != nil
    }

}

struct GroupView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let defaults = UserDefaults.standard
    let group: ChatGroup
    
    @State private var currentAccount: Account?
    @State private var roomsSections: [SocialifyClient.RoomsSection] = []
    @State private var currentRoom: SocialifyClient.GroupRoom?
    @State private var isRoomsShown: Bool = false
    
    @State var isShowPicker: Bool = false
    @State var isImagePicked: Bool = false
    @State var image: UIImage? = nil
    
    private var fetchRequest: FetchRequest<Message>
    private var messages: FetchedResults<Message> { fetchRequest.wrappedValue }
    
    private var mediaFetchRequest: FetchRequest<Media>
    private var media: FetchedResults<Media> { mediaFetchRequest.wrappedValue }
    
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("CustomAppearanceItemColor")
    
    @State private var message = ""
    
    init(group: ChatGroup) {
        self.group = group

        let predicate = NSPredicate(format: "group == %@", NSString(string: group.id!))

        self.fetchRequest = FetchRequest(
            entity: Message.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Message.id,
                    ascending: true)
            ],
            predicate: predicate
        )
        
        self.mediaFetchRequest = FetchRequest(
            entity: Media.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "chatId == %@", NSString(string: group.id!))
        )
    }
    
    var messageField: some View {
         HStack {
            Button(action: {
                withAnimation {
                    self.isShowPicker.toggle()
                }
            }) {
                Image(systemName: "paperclip")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 8)
            }
            
            TextField("Text here...", text: $message)
                .autocapitalization(.none)
                .font(Font.body.weight(Font.Weight.medium))
                .padding(.horizontal)
                .frame(height: cellHeight)
                .background(cellBackground)
                .cornerRadius(cornerRadius)
                    
            Button(action: {
                if(message != "") {
                    if(messages.count == 0) {
                        SocketIOManager.sharedInstance.sendMessage(groupId: group.id!, roomId: currentRoom!.id, message: message)
                    } else {
                        SocketIOManager.sharedInstance.sendMessage(groupId: group.id!, roomId: currentRoom!.id, message: message)
                    }
                    message = ""
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 8)
            }
            Spacer()
        }
    }
    
    var roomsView: some View {
        VStack {
            if(roomsSections.isEmpty) {
                Text("No rooms")
            } else {
                Form {
                    ForEach(roomsSections) { section in
                        Section(header: Text(section.name)) {
                            ForEach(section.rooms) { room in
                                Button(action: {
                                    isRoomsShown.toggle()
                                    
                                    currentRoom = room
                                   
                                    let dictRoom = [
                                        "id": room.id,
                                        "name": room.name,
                                        "type": String(describing: SocialifyClient.parseFromRoomType(type: room.type))
                                    ] as [String: String]
                                    
                                    defaults.set(dictRoom, forKey: "\(group.id!)CurrentRoom")
                                }) {
                                    Text(room.name)
                                        .foregroundColor(Color("CustomForegroundColor"))
                                }
                            }
                        }
                    }
                }
            }
        }

        .onAppear {
            SocketIOManager.sharedInstance.fetchRooms(groupId: group.id!) { result in
                switch(result) {
                case .success(let value):
                    roomsSections = value
                    
                case .failure:
                    print("NIE DZIAŁA!!")
                }
            }
        }
    }
    
    var messagesArea: some View {
        ForEach(Array(messages.enumerated()), id: \.element) { index, message in
            if(message.username != currentAccount?.username) {
                VStack {
                    if(index == 0 || messages[index-1].username != message.username) {
                        HStack {
                            Spacer()
                                .frame(width: 44)
                            
                            Text(message.username ?? "<username can't be loaded>")
                                .font(.caption)
                                .foregroundColor(Color("CustomForegroundColor"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 18)
                        }.padding(.bottom, -2)
                        Spacer()
                    }
                    
                    
                    HStack {
                        
                        if messages.count-1 == index || messages.count-1 > index && messages[index+1].username != message.username {
                            VStack {
                                Spacer()
                                Image(systemName: "person.circle.fill")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32)
                                    .foregroundColor(.accentColor)
                                    .padding(.trailing, 4)
                            }
                        } else {
                            VStack {
                                Spacer()
                                    .frame(width: 36)
                            }
                        }
                       
                        LeftMessageBubble(message: message, media: media)
                    }
                    Spacer()
                }.id(index)
            } else {
                HStack {
                    RightMessageBubble(message: message, media: media)
                }.id(index)
            }
        }
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
                   messagesArea
                }
            }
            Spacer()
            messageField
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isRoomsShown.toggle()
                }) {
                    Image(systemName: "arrow.up.to.line")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: GroupDetailsView(group: group)) {
                    HStack {
                        Image("Facebook")
                            .resizable()
                            .cornerRadius(360)
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(group.name!)
                                .foregroundColor(Color("CustomForegroundColor"))
                            
                            Text(currentRoom?.name ?? "<room name>")
                                .font(.caption)
                                .foregroundColor(Color("CustomForegroundColor"))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .padding(.bottom, -55)
        .sheet(isPresented: $isShowPicker) {
            ImagePicker(image: self.$image, isImagePicked: self.$isImagePicked)
        }
//        .sheet(isPresented: $isImagePicked) {
//            SendImageView(receiver: receiver, message: $message, image: $image, isImagePicked: $isImagePicked)
//        }
        .sheet(isPresented: $isRoomsShown) {
            if #available(iOS 16.0, *) {
                roomsView
                    .presentationDetents(
                        [.height(600),
                        .medium]
                    )
                    .presentationDragIndicator(.visible)
                    .padding(.top)
                    .background(Color("BackgroundForm"))
                    
            } else {
                roomsView
            }
        }
        .onAppear {
            Global.tabBar!.isHidden = true
            
            let isRoomInDefaultsExist: Bool = defaults.valueExists(forKey: "\(group.id!)CurrentRoom")
            currentAccount = client.getCurrentAccount()
            
            SocketIOManager.sharedInstance.fetchRooms(groupId: group.id!) { result in
                switch(result) {
                case .success(let value):
                    roomsSections = value
                    
                    if (!isRoomInDefaultsExist) {
                        currentRoom = value[0].rooms[0]
                        let dictRoom = [
                            "id": value[0].rooms[0].id,
                            "name": value[0].rooms[0].name,
                            "type": SocialifyClient.parseFromRoomType(type: value[0].rooms[0].type)
                        ]
                        
                        defaults.set(dictRoom, forKey: "\(group.id!)CurrentRoom")
                    } else {
                        let roomFromDefaults = defaults.object(forKey: "\(group.id!)CurrentRoom") as! [String: Any]
                        let room = [
                            "id": roomFromDefaults["id"] as! String,
                            "name": roomFromDefaults["name"] as! String,
                            "type": String(describing: roomFromDefaults["type"]!)
                        ]
                        
                        let type: Int = Int(room["type"]!) ?? 0
                        
                        currentRoom = SocialifyClient.GroupRoom(id: room["id"]!,
                                                                name: room["name"]!,
                                                                type: type)
                        
//                        let predicate = NSPredicate(format: "group == %@", group!.id)
//
//                        let dupadupa: FetchRequest<Message> = FetchRequest(
//                            entity: Message.entity(),
//                            sortDescriptors: [
//                                NSSortDescriptor(
//                                    keyPath: \Message.id,
//                                    ascending: true)
//                            ],
//                            predicate: predicate
//                        )
//
//
//                        var dupa: FetchedResults<Message> { dupadupa.wrappedValue }
//
//                        print("-=-=-=-=-=-=-=-=-=-=-=-=-")
//                        print(dupa)
//                        print("-=-=-=-=-=-=-=-=-=-=-=-=-")
                    }
                    
                case .failure:
                    print("NIE DZIAŁA!!")
                }
            }
            
            
        }
//        .onDisappear {
//            Global.tabBar!.isHidden = false
//        }
    }
}

//struct GroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupView()
//    }
//}
