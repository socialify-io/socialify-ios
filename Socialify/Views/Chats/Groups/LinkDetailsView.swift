//
//  LinkDetailsView.swift
//  Socialify
//
//  Created by Tomasz on 12/07/2022.
//

import SwiftUI
import SocialifySdk
import UniformTypeIdentifiers
import AudioToolbox

struct LinkDetailsView: View {
    let link: SocialifyClient.GroupLink
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(link.linkName ?? "No name")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("ID")
                        Spacer()
                        Text(link.id)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Link")
                        Spacer()
                        Text("Copy!")
                            .foregroundColor(.accentColor)
                    }.onTapGesture(count: 1) {
                        UIPasteboard.general.setValue(String(describing: link.link),
                            forPasteboardType: UTType.plainText.identifier)
                         AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                    }
                    
                    HStack {
                        Text("Uses")
                        Spacer()
                        if(link.isUnlimitedUses) {
                            Text("unlimited")
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(String(describing: link.uses))")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }.background(Color("BackgroundColor"))
            .navigationTitle("Link details")
    }
}
//
//struct LinkDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LinkDetailsView()
//    }
//}
