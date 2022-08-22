//
//  CreateRoomView.swift
//  Socialify
//
//  Created by Tomasz on 08/08/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct CreateRoomView: View {
    
    @Binding var isAddViewShown: Bool
    let group: ChatGroup
    let section: SocialifyClient.RoomsSection
    
    @State private var newRoomName: String = ""
    @State private var newRoomType: SocialifyClient.RoomType = SocialifyClient.RoomType.text
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Room name", text: $newRoomName)
                }
               
                Section {
                    Picker("Type", selection: $newRoomType) {
                        Text("Text").tag(SocialifyClient.RoomType.text)
                        Text("Voice").tag(SocialifyClient.RoomType.voice)
                    }
                }
            }
        }.navigationTitle("Create room")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        SocketIOManager.sharedInstance.addRoom(groupId: group.id!, sectionId: section.id, name: newRoomName, type: newRoomType) { resp in
                            switch(resp) {
                            case .success( _):
                                isAddViewShown.toggle()
                            case .failure:
                                print("NI DZIALA!!!")
                            }
                        }
                    }) {
                        Text("Create")
                            .foregroundColor(.accentColor)
                    }
                }
            }
    }
}

//struct CreateRoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateRoomView()
//    }
//}
