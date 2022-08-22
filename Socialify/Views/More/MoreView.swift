//
//  MoreView.swift
//  Socialify
//
//  Created by Tomasz on 11/05/2022.
//

import SwiftUI
import SocialifySdk
import CoreData

struct MoreView: View {
    let account: Account
    
    @State private var showEditSheet: Bool = false
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var image: UIImage? = nil
    
    @State var isShowPicker: Bool = false
    @State var isImagePicked: Bool = false
    
    init(account: Account){
        UITableView.appearance().backgroundColor = .clear
        self.account = account
    }
    
    private var appCredits: some View {
        HStack {
            Spacer()
            
            VStack {
                Group {
                    Text("Socialify alpha v0.1")
                    Text("")
                    Text("Made with ❤️ and ☕️")
                    Text("for people who need privacy")
                }
                .font(.callout)
                .opacity(0.4)
                .multilineTextAlignment(.center)
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var editHeader: some View {
        HStack {
            Spacer()
            Button(action: {
                isShowPicker.toggle()
            }) {
                VStack {
                    Image(uiImage: image ?? UIImage(data: account.avatar!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())

                    
                    Button(action: {
                        isShowPicker.toggle()
                    }) {
                        Text("Change avatar")
                    }
                }
            }
            Spacer()
        }
    }
    
    private var editAccount: some View {
        VStack {
            Form {
                Section(header: editHeader
                    .textCase(nil)
                    .foregroundColor(nil)) {}
                
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                }
                
                Section(header: Text("Bio"),
                        footer: Text("Tell something about yourself :)")) {
                    TextField("Bio", text: $bio)
                }
            }
        }
        .onAppear {
            username = account.username ?? "<username can't be loaded>"
            bio = account.bio ?? ""
            image = UIImage(data: account.avatar!)!
        }
        .sheet(isPresented: $isShowPicker) {
            ImagePicker(image: self.$image, isImagePicked: self.$isImagePicked)
        }
        .navigationTitle("Edit account")
        .navigationBarTitleDisplayMode(.inline)
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
                    if(bio != account.bio ?? "") {
                        SocketIOManager.sharedInstance.updateBio(bio: bio) { response in
                            switch(response) {
                            case .success(_):
                                showEditSheet.toggle()
                                
                            case .failure(_):
                                print("ZEPUSLO SIEE")
                            }
                        }
                    }
                    
                    if(image != UIImage(data: account.avatar!)) {
                        SocketIOManager.sharedInstance.updateAvatar(avatar: image!) { response in
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
    
    private var formHeader: some View {
        VStack {
            Image(uiImage: image ?? UIImage(data: account.avatar!)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 130)
                .clipShape(Circle())
            
            VStack {
                Text((username ?? account.username) ?? "<username can't be loaded>")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 1)
                    .foregroundColor(.primary)
                
                Text((bio ?? account.bio) ?? "<bio can't be loaded>")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: formHeader
                    .textCase(nil)
                    .foregroundColor(nil)) {
                    NavigationLink(destination: PrivacyView()) {
                        Label("Devices", systemImage: "laptopcomputer.and.iphone")
                            .accessibility(label: Text("Devices"))
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        Label("Payments", systemImage: "creditcard.fill")
                            .accessibility(label: Text("Payments"))
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        Label("Notifications", systemImage: "bell.fill")
                            .accessibility(label: Text("Notifications"))
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        Label("Security and privacy", systemImage: "network.badge.shield.half.filled")
                            .accessibility(label: Text("Privacy"))
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("Data and synchronization", systemImage: "externaldrive.fill.badge.icloud")
                            .accessibility(label: Text("Data and synchronization"))
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("Emoji", systemImage: "face.smiling.fill")
                            .accessibility(label: Text("Emoji"))
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("Appearance", systemImage: "eye.fill")
                            .accessibility(label: Text("Appearance"))
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("Language", systemImage: "globe.europe.africa.fill")
                            .accessibility(label: Text("Language"))
                    }
                }
                
                Section(footer: appCredits) {
                    NavigationLink(destination: ContributorsView()) {
                        Label("App developers team", systemImage: "person.2.fill")
                            .accessibility(label: Text("App developers team"))
                    }
                    
                    NavigationLink(destination: LicenceView()) {
                        Label("Open-source licences", systemImage: "books.vertical.fill")
                            .accessibility(label: Text("Open-source licences"))
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("Invite a friend!", systemImage: "envelope.fill")
                            .accessibility(label: Text("Invite a friend!"))
                    }
                    
                    Link(destination: URL(string: "https://socialify.me")!) {
                        
                        NavigationLink(destination: DataView()) {
                            Label {
                                Text("Website")
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "network")
                            }
                                .accessibility(label: Text("Website"))
                        }
                                    
                        
//                        HStack {
//                            Label("", systemImage: "network")
//                                .accessibility(label: Text("Website"))
//                                .padding(.trailing, 0)
//
//                            Text("Website")
//                                .foregroundColor(.primary)
//                                .padding(.leading, -9)
//
//                            Spacer()
//
//                            Label("", systemImage: "chevron.right")
//                                .foregroundColor(.secondary)
//                        }
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("FAQ", systemImage: "questionmark")
                            .accessibility(label: Text("FAQ"))
                    }
                    
                    NavigationLink(destination: DataView()) {
                        Label("Contact", systemImage: "person.crop.square.filled.and.at.rectangle.fill")
                            .accessibility(label: Text("Contact"))
                    }

                    NavigationLink(destination: DataView()) {
                        Label("About project", systemImage: "person.crop.rectangle.fill")
                            .accessibility(label: Text("About project"))
                    }
                    
                }
            }
            .background(Color("BackgroundColor"))
        }
        //.navigationBarTitle("Settings", displayMode: .inline)
//        .navigationBarTitle(account.username ?? "<username can't be loaded>", displayMode: .inline)
        .background(Color("BackgroundColor"))
        .onAppear {
            image = UIImage(data: account.avatar!)
            username = account.username!
            bio = account.bio!
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("dupa")
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showEditSheet.toggle()
                }) {
                    Text(" Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                editAccount
            }
        }
    }
}

//struct MoreView_Previews: PreviewProvider {
//    static var previews: some View {
//        MoreView()
//    }
//}
