//
//  GroupView.swift
//  Socialify
//
//  Created by Tomasz on 05/07/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct GroupView: View {
    let defaults = UserDefaults.standard
    let group: ChatGroup
    
    @State private var roomsSections: [SocialifyClient.RoomsSection] = []
    @State private var currentRoom: SocialifyClient.GroupRoom?
    @State private var isRoomsShown: Bool = false
   
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
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }.background(Color("BackgroundColor"))
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
            
            let roomFromDefaults = defaults.object(forKey: "\(group.id!)CurrentRoom") as! [String: Any]
            
            print("-=-=-=-=-=-=-=-=-=-=-=-=-")
            print(roomFromDefaults)
            print("-=-=-=-=-=-=-=-=-=-=-=-=-")
            
            SocketIOManager.sharedInstance.fetchRooms(groupId: group.id!) { result in
                switch(result) {
                case .success(let value):
                    roomsSections = value
                    
                    if (roomFromDefaults == nil) {
                        currentRoom = value[0].rooms[0]
                        let dictRoom = [
                            "id": value[0].rooms[0].id ,
                            "name": value[0].rooms[0].name ,
                            "type": SocialifyClient.parseFromRoomType(type: value[0].rooms[0].type)
                        ]
                        
                        defaults.set(dictRoom, forKey: "\(group.id!)CurrentRoom")
                    } else {
                        let room = [
                            "id": roomFromDefaults["id"] as! String,
                            "name": roomFromDefaults["name"] as! String,
                            "type": String(describing: roomFromDefaults["type"]!)
                        ]
                        
                        let type: Int = Int(room["type"]!) ?? 0
                        
                        currentRoom = SocialifyClient.GroupRoom(id: room["id"]!,
                                                                name: room["name"]!,
                                                                type: type)
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
