//
//  DMView.swift
//  DMView
//
//  Created by Tomasz on 22/08/2021.
//

import SwiftUI
import SocialifySdk
import CoreData

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DMView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    @State var isShowPicker: Bool = false
    @State var isImagePicked: Bool = false
    @State var image: UIImage? = nil
    
    @State private var currentAccount: Account?
    
    let receiver: User
    
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("CustomAppearanceItemColor")
    
    @State private var message = ""
    //@State var messages: [DM] = []
    
    @State private var sameSenderInARow: CGFloat = 0
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    private var fetchRequest: FetchRequest<DM>
    private var messages: FetchedResults<DM> { fetchRequest.wrappedValue }
    
    private var mediaFetchRequest: FetchRequest<Media>
    private var media: FetchedResults<Media> { mediaFetchRequest.wrappedValue }
    
    init(receiver: User) {
        self.receiver = receiver
        
        let predicateForReceivedMessageReceived = NSPredicate(format: "receiverId == %@", NSString(string: SocialifyClient.shared.getCurrentAccount().userId!))
        let predicateForSendMessageReceived = NSPredicate(format: "receiverId == %@", NSString(string: receiver.id!))
        let predicateForSendMessageSend = NSPredicate(format: "senderId == %@", NSString(string: SocialifyClient.shared.getCurrentAccount().userId!))
        let predicateForReceivedMessageSend = NSPredicate(format: "senderId == %@", NSString(string: receiver.id!))
        
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
        
        self.mediaFetchRequest = FetchRequest(
            entity: Media.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "chatId == %@", NSString(string: receiver.id!))
        )
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
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
                                       
                                        LeftDMBubble(message: message, media: media)
                                    }
                                    Spacer()
                                }.id(index)
                            } else {
                                HStack {
                                    RightDMBubble(message: message, media: media)
                                }.id(index)
                            }
                    }
                }
                .onChange(of: messages.count) { _ in
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
                            SocketIOManager.sharedInstance.sendDM(message: message, receiver: receiver, image: nil)
                        } else {
                            SocketIOManager.sharedInstance.sendDM(message: message, receiver: receiver, image: nil)
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
            }//.shadow(color: Color("ShadowColor"), radius: 5)
            
    }.padding()
        //.background(Color("BackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gear")
                }
            }
        }
        .background(Color("BackgroundColor"))
        .sheet(isPresented: $isShowPicker) {
            ImagePicker(image: self.$image, isImagePicked: self.$isImagePicked)
        }
        .sheet(isPresented: $isImagePicked) {
            SendImageView(receiver: receiver, message: $message, image: $image, isImagePicked: $isImagePicked)
        }
        .onAppear {
            self.currentAccount = client.getCurrentAccount()
            SocketIOManager.sharedInstance.fetchDMs(chatId: receiver.id!)
            
            for message in messages {
                message.isRead = true
            }
            
            
            let context = self.client.persistentContainer.viewContext
            try! context.save()
//            print("{{{{{{{{FETCH REQUEST}}}}}}}}}}}")
//            print(fetchRequest)
//            print("{{{{{{{{FETCH REQUEST}}}}}}}}}}}")
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
