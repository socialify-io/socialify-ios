//
//  AddGroupMembersView.swift
//  Socialify
//
//  Created by Tomasz on 05/07/2022.
//

import SwiftUI
import SocialifySdk
import CoreData
import Combine
import AudioToolbox

struct AddGroupMembersView: View {
    let group: ChatGroup
   
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("CustomAppearanceItemColor")
    let borderColor: Color = Color(UIColor.systemGray).opacity(0)
    
    @State private var links: [SocialifyClient.GroupLink] = []
    
    @State var isCreateLinkClicked: Bool = false
    
    @State private var newLinkName = ""
    @State private var numberOfUses = "1"
    @State private var isUnlimitedUses: Bool = true
    @State private var isExpiryDateSet: Bool = false
    @State private var isAdminApprovalNeeded: Bool = false
    @State private var expiryDate = Date()
    let dateRange: ClosedRange<Date> = {
        //TODO: fix date components
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    private var createLinkForm: some View {
        VStack {
            Form {
                Section(header: Text("Link name"),
                        footer: Text("If you leave this field empty, id will be shown as the link name")) {
                    TextField(LocalizedStringKey("Link name (optional)"), text: $newLinkName)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.leading)
                }
                
                Section {
                    Toggle(isOn: $isAdminApprovalNeeded) {
                        Text("Admin approval needed")
                    }
                }
                    
                Section(header: Text("Number of uses")) {
                    Toggle(isOn: $isUnlimitedUses) {
                        Text("Unlimited")
                    }
                    
                    if (!isUnlimitedUses) {
                        HStack {
                            Text("Number of uses: ")
                            
                            Spacer()
                            
                            TextField(LocalizedStringKey(""), text: $numberOfUses)
                                .autocapitalization(.none)
                                //.font(Font.body.weight(Font.Weight.medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .frame(width: cellHeight*1.2, height: cellHeight/1.4)
                                .background(Color("BackgroundPickerColor"))
                                .keyboardType(.decimalPad)
                                .cornerRadius(cornerRadius)
                                .onReceive(numberOfUses.publisher.collect()) {
                                    let s = String($0.prefix(3))
                                    if numberOfUses != s {
                                        numberOfUses = s
                                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                                    }
                                }
                                .onReceive(Just(numberOfUses)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.numberOfUses = filtered
                                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                                    }
                                }
                            }
                        }
                    }
                
                Section(header: Text("Expiry date")) {
                    Toggle(isOn: $isExpiryDateSet) {
                        Text("Expiry date")
                    }
                    
                    if (isExpiryDateSet) {
                        DatePicker(
                            "Expiry date:",
                             selection: $expiryDate,
                             in: dateRange,
                             displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
        }.navigationTitle("Create link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isCreateLinkClicked.toggle() }) {
                        Text("Cancel")
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        SocketIOManager.sharedInstance.createInviteLink(
                            groupId: group.id!,
                            linkName: newLinkName,
                            isAdminApprovalNeeded: isAdminApprovalNeeded,
                            isUnlimitedUses: isUnlimitedUses,
                            isExpiryDateSet: isExpiryDateSet,
                            numberOfUses: numberOfUses,
                            expiryDate: expiryDate
                        ) { value in
                            switch(value) {
                            case .success:
                                isCreateLinkClicked.toggle()
                                
                            case .failure:
                                print("NIE DZIALA")
                            }
                        }
                    }) {
                        Text("Create")
                            .foregroundColor(.accentColor)
                    }
                }
            }.background(Color("BackgroundColor"))
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add members")) {
                    Button(action: { isCreateLinkClicked.toggle() }) {
                        HStack {
                            Image(systemName: "link")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 22)
                                .foregroundColor(Color("CustomForegroundColor"))

                            Text("Create new link")
                                .padding(.leading, 12)
                                .foregroundColor(Color("CustomForegroundColor"))
                            
                            Spacer()
                            
                            Image(systemName: "plus")
                                .foregroundColor(.accentColor)
                        }.padding(.vertical, 10)
                    }
                }
           
                Section(header: Text("Active links")) {
                        if (links.isEmpty) {
                            Text("No active links")
                        } else {
                            ForEach(links) { link in
                                NavigationLink(destination: LinkDetailsView(link: link)) {
                                    Text(link.linkName ?? link.id)
                                }
                            }
                        }
                    }
            }
        }.onAppear {
            Global.tabBar!.isHidden = true
            
            SocketIOManager.sharedInstance.getInviteLinks(groupId: group.id!) { resp in
                switch(resp) {
                case .success(let value):
                    links = value
                case .failure:
                    print("NI DZIALA!!!")
                }
            }
        }.background(Color("BackgroundColor"))
            .navigationTitle("Add members")
            .sheet(isPresented: $isCreateLinkClicked) {
                NavigationView {
                    createLinkForm
                }
            }
    }
}

//struct AddGroupMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddGroupMembersView()
//    }
//}
