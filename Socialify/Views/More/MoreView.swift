//
//  MoreView.swift
//  Socialify
//
//  Created by Tomasz on 11/05/2022.
//

import SwiftUI

struct MoreView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
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
    
    var body: some View {
        VStack {
            Form {
                Section {
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
        .navigationBarTitle("Settings", displayMode: .inline)
        .background(Color("BackgroundColor"))
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
