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
   
    @State private var isShowPicker: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var isImagePicked: Bool = false
    
    @State private var name: String = ""
    @State private var about: String = ""
    @State private var icon: UIImage? = nil
    
    private var editHeader: some View {
        HStack {
            Spacer()
            Button(action: {
                isShowPicker.toggle()
            }) {
                VStack {
                    Image(uiImage: icon ?? UIImage(data: group.icon!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())

                    
                    Button(action: {
                        isShowPicker.toggle()
                    }) {
                        Text("Change icon")
                    }
                }
            }
            Spacer()
        }
    }
    
    private var editView: some View {
        VStack {
            Form {
                Section(header: editHeader
                    .textCase(nil)
                    .foregroundColor(nil)) {}
                
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("About"),
                        footer: Text("Tell something about this group")) {
                    TextField("About", text: $about)
                }
            }
        }.navigationTitle("Edit group")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowPicker) {
            ImagePicker(image: self.$icon, isImagePicked: self.$isImagePicked)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showEditSheet.toggle()
                }) {
                    Text("Cancel")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if(icon != UIImage(data: group.icon!)) {
                        SocketIOManager.sharedInstance.updateGroupIcon(groupId: group.id!, icon: icon!) { response in
                            switch(response) {
                            case .success(_):
                                showEditSheet.toggle()
                                
                            case .failure(_):
                                print("ZEPUSLO SIEE")
                            }
                        }
                    }
                }) {
                    Text("Done")
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
            VStack {
                ZStack {
                    Image(uiImage: UIImage(data: group.icon!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 92, height: 92)
                        .padding(.bottom, 150)
                        .zIndex(2)

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

                }.padding(.horizontal)
                    .padding(.bottom)
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
            
            icon = UIImage(data: group.icon!)
            name = group.name!
            about = group.groupDescription!
        }.background(Color("BackgroundForm"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditSheet.toggle()
                }) {
                    Text("Edit ")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                editView
            }
        }
        
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
