//
//  RoomsEditView.swift
//  Socialify
//
//  Created by Tomasz on 03/08/2022.
//

import SwiftUI
import CoreData
import SocialifySdk

struct RoomsEditView: View {
    
    let group: ChatGroup
    @State private var roomsSections: [SocialifyClient.RoomsSection] = []
    @State private var isAddRoomsSheetOpened: Bool = false
    @State private var isAddViewShown: Bool = false
    @State private var addView: String = "Section"
    @State private var newSectionName: String = ""
    
    private var addSectionView: some View {
        VStack{
            Form {
                TextField("Section name", text: $newSectionName)
            }
        }.navigationTitle("Create section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isAddViewShown.toggle() }) {
                        Text("Cancel")
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        SocketIOManager.sharedInstance.addSection(groupId: group.id!, name: newSectionName) { resp in
                            switch(resp) {
                            case .success( _):
                                newSectionName = ""
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
            }.background(Color("BackgroundColor"))
    }
    
    private var addRoomView: some View {
        VStack{
            Form {
                ForEach(roomsSections) { section in
                    Section(header:
                        HStack {
                            Text(section.name)
                            NavigationLink(destination: CreateRoomView(isAddViewShown: $isAddViewShown, group: group, section: section)) {
                                Image(systemName: "plus")
                            }
                        }
                    ) {
                        ForEach(section.rooms) { room in
                            Button(action: {
                                print("dupa")
                            }) {
                                Text(room.name)
                                    .foregroundColor(Color("CustomForegroundColor"))
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    print("\(room.name) is being deleted.")
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isAddViewShown.toggle() }) {
                        Text("Cancel")
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Chats")
                        .bold()
                }
                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        SocketIOManager.sharedInstance.addSection(groupId: group.id!, name: newSectionName) { resp in
//                            switch(resp) {
//                            case .success( _):
//                                newSectionName = ""
//                                isAddViewShown.toggle()
//                            case .failure:
//                                print("NI DZIALA!!!")
//                            }
//                        }
//                    }) {
//                        Text("Create")
//                            .foregroundColor(.accentColor)
//                    }
                }
    }
    
    var body: some View {
        VStack {
            Form {
                ForEach(roomsSections) { section in
                    Section(header: Text(section.name)) {
                        ForEach(section.rooms) { room in
                            Button(action: {
                                print("dupa")
                            }) {
                                Text(room.name)
                                    .foregroundColor(Color("CustomForegroundColor"))
                            }
                        }
                    }
                }
            }
        }.onAppear {
            SocketIOManager.sharedInstance.fetchRooms(groupId: group.id!) { result in
                switch(result) {
                case .success(let value):
                    roomsSections = value
                    
                case .failure:
                    print("NIE DZIAŁA!!")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isAddRoomsSheetOpened.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .confirmationDialog("Select option", isPresented: $isAddRoomsSheetOpened) {
            Button(action: {
                addView = "Section"
                isAddViewShown.toggle()
            }) {
                Text("Section")
            }
            
            Button(action: {
                addView = "Room"
                isAddViewShown.toggle()
            }) {
                Text("Room")
            }
        }
        .sheet(isPresented: $isAddViewShown) {
            NavigationView {
                if (addView == "Section") {
                    addSectionView
                } else {
                    addRoomView
                }
            }
        }
    }
}

//struct RoomsEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomsEditView()
//    }
//}
