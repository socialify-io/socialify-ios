//
//  DMView.swift
//  DMView
//
//  Created by Tomasz on 22/08/2021.
//

import SwiftUI
import SocialifySdk
import CoreData

struct DMView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State private var currentAccount: Account?
    
    let receiver: User
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(.systemGray6)
    
    @State private var message = ""
    //@State var messages: [DM] = []
    
    @State private var sameSenderInARow: CGFloat = 0
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    private var fetchRequest: FetchRequest<DM>
    private var messages: FetchedResults<DM> { fetchRequest.wrappedValue }
    
    init(receiver: User) {
        self.receiver = receiver
        
        let predicateForReceivedMessageReceived = NSPredicate(format: "receiverId == %@", NSNumber(value: SocialifyClient.shared.getCurrentAccount().userId))
        let predicateForSendMessageReceived = NSPredicate(format: "receiverId == %@", NSNumber(value: receiver.id))
        let predicateForSendMessageSend = NSPredicate(format: "senderId == %@", NSNumber(value: SocialifyClient.shared.getCurrentAccount().userId))
        let predicateForReceivedMessageSend = NSPredicate(format: "senderId == %@", NSNumber(value: receiver.id))
        
        let predicateAndReceived = NSCompoundPredicate(type: .and, subpredicates: [predicateForReceivedMessageSend, predicateForReceivedMessageReceived])
        let predicateAndSend = NSCompoundPredicate(type: .and, subpredicates: [predicateForSendMessageSend, predicateForSendMessageReceived])
        
        let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateAndSend, predicateAndReceived])
        
        self.fetchRequest = FetchRequest(
            entity: DM.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \DM.id,
                    ascending: true)
            ],
            predicate: finalPredicate
        )
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
                    ForEach(Array(messages.enumerated()), id: \.element) { index, message in
                        if(messages[index].receiverId == receiver.id && messages[index].senderId == currentAccount?.userId || messages[index].receiverId == currentAccount?.userId && messages[index].senderId == receiver.id) {
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
                                        if(messages.count-1 == index || messages.count-1 > index && messages[index+1].username != message.username) {
                                            VStack {
                                                Image(systemName: "person.circle.fill")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 40)
                                                    .foregroundColor(.accentColor)
                                                    .padding(.trailing, 4)
                                            }
                                        } else {
                                            VStack {
                                                Spacer()
                                                    .frame(width: 44)
                                            }
                                        }
                                        
                                        HStack {
                                            Text(message.message ?? "<message can't be loaded>")
                                        }.padding(.vertical, 12)
                                        .padding(.horizontal)
                                        .background(Color("CustomAppearanceItemColor"))
                                        .cornerRadius(20)
                                        .shadow(color: Color("ShadowColor"), radius: 5)
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }.id(index)
                            } else {
                                HStack {
                                    Spacer()
                                    
                                    HStack {
                                        Text(message.message ?? "<message can't be loaded>")
                                    }.padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(Color("CustomAppearanceItemColor"))
                                    .cornerRadius(20)
                                    .shadow(color: Color("ShadowColor"), radius: 5)
                                    .padding(.trailing, 5)
                                }.id(index)
                            }
                        }
                    }
                }.onChange(of: messages.count) { _ in
                    value.scrollTo(messages.count - 1)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        value.scrollTo(messages.count - 1)
                    }
                }
            }
            Spacer()
            HStack {
                TextField("Text here...", text: $message)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                
                Button(action: {
                    if(message != "") {
                        SocketIOManager.sharedInstance.sendDM(message: message, id: receiver.id)
                        message = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 8)
                }
                Spacer()
            }.shadow(color: Color("ShadowColor"), radius: 5)
        }.padding()
        .background(Color("BackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            self.currentAccount = client.getCurrentAccount()
            print("{{{{{{{{FETCH REQUEST}}}}}}}}}}}")
            print(fetchRequest)
            print("{{{{{{{{FETCH REQUEST}}}}}}}}}}}")
            //self.messages = SocketIOManager.sharedInstance.getDMsFromDB(user: receiver)
        }
//        .onDisappear {
//            SocketIOManager.sharedInstance.stopReceivingMessages()
//        }
    }
}

//struct DMView_Previews: PreviewProvider {
//    static var previews: some View {
//        DMView()
//    }
//}
