//
//  dm.swift
//  dm
//
//  Created by Tomasz on 22/08/2021.
//

import Foundation
import CoreData
import SwiftUI

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 0.1)!.base64EncodedString()
    }
}

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func sendDM(message: String, id: Int64, image: UIImage?) {
        if(image != nil) {
            let base64image = image?.base64
            
            let payload = ["receiverId": id,
                           "message": message,
                           "media": [[
                                "type": 1,
                                "media": base64image
                           ]]] as [String : Any]
            
            socket.emit("send_dm", payload)
        } else {
            socket.emit("send_dm", ["receiverId": id,
                                    "message": message,
                                    "media": []])
        }
    }
    
    public func fetchDMs(chatId: Int64) {
        let context = self.client.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
//        fetchRequest.predicate = NSPredicate(format: "chatId == %@", NSNumber(value: chatId))
//        let chat = try! context.fetch(fetchRequest) as! [Chat]

//        let DMFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
//        let senderPredicate = NSPredicate(format: "senderId == %@", NSNumber(value: chatId))
//        let receiverPredicate = NSPredicate(format: "receiverId == %@", NSNumber(value: chatId))
//        DMFetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: [senderPredicate, receiverPredicate])
        
        
        self.socket.emit("fetch_dms", ["sender": chatId])
        
        self.socket.on("fetch_dms") { dataArray, socketAck in
            
            let data: [[String: Any]] = dataArray[0] as! [[String: Any]]
            
            for dm in data {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
                fetchRequest.predicate = NSPredicate(format: "id == %@", dm["id"] as! CVarArg)
                let allDMsWithSameId = try! context.fetch(fetchRequest) as! [DM]
                
                if(allDMsWithSameId == []) {
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "DM",
                        in: context
                    )!
                    
                    let DMModel = DM(
                        entity: entityDescription,
                        insertInto: context
                    )
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let date = dateFormatter.date(from: "\(dm["date"]!)")
                    
                    
                    let receiverId: Int = Int("\(dm["receiver"] ?? "")")!
                    let senderId: Int = Int("\(dm["sender"] ?? "")")!
                    
                    DMModel.username = dm["username"] as? String
                    DMModel.message = dm["message"] as? String
                    DMModel.date = date
                    DMModel.id = dm["id"] as! Int64
                    DMModel.senderId = Int64("\(String(describing: senderId))")!
                    DMModel.receiverId = Int64("\(String(describing: receiverId))")!
                    
//                    let fetchChatRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
//                    fetchChatRequest.predicate = NSPredicate(format: "chatId == %@", NSNumber(value: chatId))
//                    var chat = try! context.fetch(fetchChatRequest) as! [Chat]
//
//                    if(chat != []) {
//                        chat[0].lastMessage = DMModel.message
//                        chat[0].lastMessageAuthor = DMModel.username
//                        chat[0].lastMessageId = DMModel.id
//                        chat[0].date = DMModel.date
//                        chat[0].isRead = true
//                    }
//
//                    var chatId: Int64
//                    let currentAccount = self.client.getCurrentAccount()
//
//                    if(DMModel.receiverId == currentAccount.userId) { chatId = DMModel.senderId }
//                    else { chatId = DMModel.receiverId }
                    
                    let media = dm["media"] as! [[String: Any]]
                
                    for mediaElement in media {
                        let entityDescription = NSEntityDescription.entity(
                            forEntityName: "Media",
                            in: context
                        )!

                        let MediaModel = Media(
                            entity: entityDescription,
                            insertInto: context
                        )
                        
                        MediaModel.chatId = NSDecimalNumber(value: chatId)
                        MediaModel.type = mediaElement["type"] as! Int16
                        MediaModel.messageId = NSDecimalNumber(value: DMModel.id)
                        MediaModel.url = mediaElement["mediaURL"] as! String
                    }
                        
                    
                    try! context.save()
                }
                self.socket.emit("delete_dms", ["sender": chatId, "from": dm["id"], "to": dm["id"]])
            }
            //self.sortChats(chatId: chatId)
        }
    }
    
    public func getDMMessage(completion: @escaping (DM) -> Void) {
        socket.on("send_dm") { dataArray, socketAck in
            print("dostałem wiadomość")
            let context = self.client.persistentContainer.viewContext

            let data = dataArray[0] as! [String: Any]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
            fetchRequest.predicate = NSPredicate(format: "id == %@", data["id"] as! CVarArg)
            let allDMsWithSameId = try! context.fetch(fetchRequest) as! [DM]
            
            let receiverId: Int = Int("\(data["receiverId"] ?? "")")!
            let senderId: Int = Int("\(data["senderId"] ?? "")")!
            
            var chatId: Int64
            let currentAccount = self.client.getCurrentAccount()
            
            if(receiverId == currentAccount.userId) { chatId = Int64(senderId) }
            else { chatId = Int64(receiverId) }
            
            print("+++++")
            print(allDMsWithSameId)
            print("+++++")
        
            if(allDMsWithSameId == []) {
                let entityDescription = NSEntityDescription.entity(
                    forEntityName: "DM",
                    in: context
                )!

                let DMModel = DM(
                    entity: entityDescription,
                    insertInto: context
                )
                
//                let predicateForReceivedMessageReceived = NSPredicate(format: "receiverId == %@", NSNumber(value: receiverId))
//                let predicateForSendMessageReceived = NSPredicate(format: "receiverId == %@", NSNumber(value: senderId))
//                let predicateForSendMessageSend = NSPredicate(format: "senderId == %@", NSNumber(value: senderId))
//                let predicateForReceivedMessageSend = NSPredicate(format: "senderId == %@", NSNumber(value:  receiverId))
//
//                let predicateAndReceived = NSCompoundPredicate(type: .and, subpredicates: [predicateForReceivedMessageSend, predicateForReceivedMessageReceived])
//                let predicateAndSend = NSCompoundPredicate(type: .and, subpredicates: [predicateForSendMessageSend, predicateForSendMessageReceived])
//
//                let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateAndSend, predicateAndReceived])
//
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
//                fetchRequest.predicate = finalPredicate
//                fetchRequest.sortDescriptors = [NSSortDescriptor(
//                                                keyPath: \DM.id,
//                                                ascending: true)]
//
//                var messages = try! context.fetch(fetchRequest) as! [DM]
    //            if(messages.count >= 16) {
    //                try! context.delete(messages.last!)
    //            }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: "\(data["date"]!)")

                DMModel.username = data["username"] as? String
                DMModel.message = data["message"] as? String
                DMModel.date = date
                DMModel.id = data["id"] as! Int64
                DMModel.senderId = Int64("\(String(describing: senderId))")!
                DMModel.receiverId = Int64("\(String(describing: receiverId))")!
                
                let media = data["media"] as! [[String: Any]]
                
                for mediaElement in media {
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "Media",
                        in: context
                    )!

                    let MediaModel = Media(
                        entity: entityDescription,
                        insertInto: context
                    )
                    
                    MediaModel.chatId = NSDecimalNumber(value: chatId)
                    MediaModel.type = mediaElement["type"] as! Int16
                    MediaModel.messageId = NSDecimalNumber(value: DMModel.id)
                    MediaModel.url = mediaElement["mediaURL"] as! String
                }
                
                self.sortChats(chatId: chatId)

                try! context.save()
            }
            self.socket.emit("delete_dms", ["sender": chatId, "from": data["id"], "to": data["id"]])
        }
    }
    
    public func stopReceivingMessages() {
        socket.off("send_dm")
    }
    
    private func sortChats(chatId: Int64) {
        let context = self.client.persistentContainer.viewContext
        let currentAccount = self.client.getCurrentAccount()
        var chats = self.getChats()
        
        if(self.isChatInDB(chatId: chatId)) {
            for chat in chats {
                if(chat.chatId == chatId) {
                    chat.id = 0
                    break
                } else {
                    chat.id += 1
                }
            }

            chats = chats.sorted { $0.id > $1.id }
            try! context.save()
        } else {
            let entityDescription = NSEntityDescription.entity(
                forEntityName: "Chat",
                in: context
            )!

            let newChatModel = Chat(
                entity: entityDescription,
                insertInto: context
            )
            
            for chat in chats {
                chat.id += 1
            }

            newChatModel.userId = currentAccount.id
            newChatModel.chatId = chatId
            newChatModel.id = 0 as Int64
            
            self.socket.emit("get_information_about_account", Int(chatId))

            self.socket.on("get_information_about_account") { dataArray, socketAck in
                let data = dataArray[0] as! [String: Any]
                newChatModel.name = data["username"] as? String
                //model.avatar = data["avatar"] as? String
                //print(model.avatar)
                chats = chats.sorted { $0.id > $1.id }
                try! context.save()
                self.socket.off("get_information_about_account")
            }
        }
    }
     
    
//    public func getLastUnreadChats() -> [Chat] {
//        let context = self.client.persistentContainer.viewContext
//        socket.emit("fetch_last_unread_dms")
//        socket.on("fetch_last_unread_dms") { dataArray, socketAck in
//            let entityDescription = NSEntityDescription.entity(
//                forEntityName: "Chat",
//                in: context
//            )!
//
//            let data = dataArray[0] as? [String: Any]
//            print("======")
//            print(data)
//            print("======")
//            if(data != nil) {
//                let model = Chat(
//                    entity: entityDescription,
//                    insertInto: context
//                )
//
//                let receiver = data!["receiver"]!
//                let sender = data!["sender"]
//                let isRead = data!["isRead"]
//
//                model.name = data!["username"] as? String
//                model.lastMessage = data!["message"] as? String
//                model.date = data!["date"] as? Date
//                model.userId = Int64(self.getDMId(receiver: receiver as! Int, sender: sender as! Int) + 1)
//                model.chatId = Int64("\(String(describing: sender!))")!
//                model.type = "DM"
//                model.isRead = isRead as! Bool
//
//                try! context.save()
//            }
//        }
//    }
        
    public func getChats() -> [Chat] {
        let context = self.client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let chats = try! context.fetch(fetchRequest) as! [Chat]

        let currentAccount = self.client.getCurrentAccount()

        var chatsForUser: [Chat] = []
        for chat in chats {
            if(chat.userId == currentAccount.id) {
                chatsForUser.append(chat)
            }
        }

        return chatsForUser.sorted { $0.id < $1.id }
    }
        
    func getDMId() -> Int {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
        let messages = try! context.fetch(fetchRequest) as! [DM]

        var messageId: Int = 0
        if(messages != []) {
            for _ in messages {
                messageId+=1
            }
        }
        return messageId
    }
        
    func isChatInDB(chatId: Int64) -> Bool {
        let chats = getChats()

        for chat in chats {
            if(chat.chatId == chatId) {
                return true
            }
        }

        return false
    }
    
    public func getDMsFromDB(user: User) -> [DM] {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
        let messages = try! context.fetch(fetchRequest) as! [DM]

        let currentAccount = client.getCurrentAccount()

        var messagesForRoom: [DM] = []
        if(messages != []) {
            for message in messages {
                if(message.receiverId == user.id && message.senderId == currentAccount.userId || message.receiverId == currentAccount.userId && message.senderId == user.id) {
                    messagesForRoom.append(message)
                }
            }
        }

        return messagesForRoom
    }
}

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    public func chatToUser(chat: Chat) -> User {
        let context = self.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "User",
            in: context
        )!
        
        let model = User(
            entity: entityDescription,
            insertInto: context
        )
        
        model.avatar = chat.avatar
        model.username = chat.name
        model.id = chat.chatId
        
        return model
    }
}
    
    

//
//    public func getLastDMs() -> [LastDM] {
//        let context = self.client.persistentContainer.viewContext
//        socket.emit("fetch_last_unread_dms")
//        socket.on("fetch_last_unread_dms") { dataArray, socketAck in
//            let entityDescription = NSEntityDescription.entity(
//                forEntityName: "LastDM",
//                in: context
//            )!
//
//            let model = LastDM(
//                entity: entityDescription,
//                insertInto: context
//            )
//
//            let data = dataArray[0] as! [String: Any]
//            let receiverId = data["receiver"]
//            let senderId = data["sender"]
//
//            model.username = data["username"] as? String
//            model.lastMessage = data["message"] as? String
//            model.date = data["date"] as? Date
//            model.userId = Int64(self.getLastDMId(receiverId: receiverId as! Int, senderId: senderId as! Int) + 1)
//            model.receiverId = Int64("\(String(describing: senderId!))")!
//
//            try! context.save()
//        }
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastDM")
//        let dms = try! context.fetch(fetchRequest) as! [LastDM]
//
//        let currentAccount = self.client.getCurrentAccount()
//
//        var lastDMsForUser: [LastDM] = []
//        for dm in dms {
//            if(dm.userId == currentAccount.id) {
//                lastDMsForUser.append(dm)
//            }
//        }
//
//        return lastDMsForUser.sorted { $0.id < $1.id }
//    }
//
//    private func getLastDMId(receiverId: Int, senderId: Int) -> Int {
//        let context = client.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
//        let messages = try! context.fetch(fetchRequest) as! [DM]
//
//        var messageId: Int = 0
//        if(messages != []) {
//            for message in messages {
//                if(message.receiverId == receiverId && message.senderId == senderId || message.receiverId == senderId && message.senderId == receiverId) {
//                    messageId+=1
//                }
//            }
//        }
//        return messageId
//    }
//
//    private func setLastDM(receivedDM: DM) {
//        let context = client.persistentContainer.viewContext
//        let currentAccount = client.getCurrentAccount()
//        var dms = getLastDMs()
//
//        var userId: Int64
//
//        if(receivedDM.receiverId == currentAccount.userId) { userId = receivedDM.senderId }
//        else { userId = receivedDM.receiverId }
//
//        if(isReceiverIdInDB(receiverId: userId)) {
//            for dm in dms {
//                if(dm.receiverId == userId) {
//                    dm.id = 0
//                } else {
//                    dm.id += 1
//                }
//            }
//
//            dms = dms.sorted { $0.id > $1.id }
//            try! context.save()
//        } else {
//            let entityDescription = NSEntityDescription.entity(
//                forEntityName: "LastDM",
//                in: context
//            )!
//
//            let model = LastDM(
//                entity: entityDescription,
//                insertInto: context
//            )
//
//            for dm in dms {
//                dm.id += 1
//            }
//
//            model.userId = currentAccount.id
//            model.receiverId = userId
//            model.id = 0 as Int64
//
//            socket.emit("get_information_about_account", Int(userId))
//
//            socket.on("get_information_about_account") { dataArray, socketAck in
//                let data = dataArray[0] as! [String: Any]
//                model.username = data["username"] as? String
//                //model.avatar = data["avatar"] as? String
//                //print(model.avatar)
//                dms = dms.sorted { $0.id > $1.id }
//                try! context.save()
//            }
            
//            let url = URL(string: "\(client.API_ROUTE)v\(client.API_VERSION)/getInformationAboutAccount")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let payload: [String: Any] = [
//                "userId": userId
//            ]
//            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
//
//            let timestamp = NSDate().timeIntervalSince1970
//            let authToken = client.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "getInformationAboutAccount")
//
//            request.addValue(authToken ?? "", forHTTPHeaderField: "AuthToken")
//
//            DispatchQueue.main.async { [self] in
//                client.request(request: request, timestamp: timestamp) { value in
//                    switch value {
//                    case .success(let response):
//                        model.username = response["data"]["username"].stringValue
//                        model.avatar = response["data"]["avatar"].stringValue
//
//                        dms = dms.sorted { $0.id > $1.id }
//                        try! context.save()
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//            }
//        }
//    }
//
//    private func isReceiverIdInDB(receiverId: Int64) -> Bool {
//        let dms = getLastDMs()
//
//        for dm in dms {
//            if(dm.receiverId == receiverId) {
//                return true
//            }
//        }
//
//        return false
//    }
