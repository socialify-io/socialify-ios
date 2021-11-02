//
//  dm.swift
//  dm
//
//  Created by Tomasz on 22/08/2021.
//

import Foundation
import CoreData

@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func sendDM(message: String, id: Int64) {
        socket.emit("send_dm", ["receiverId": id,
                                "message": message])
    }
    
    public func getDMMessage(completion: @escaping (DM) -> Void) {
        socket.on("send_dm") { dataArray, socketAck in
            print("dostałem wiadomość")
            let context = self.client.persistentContainer.viewContext

            let entityDescription = NSEntityDescription.entity(
                forEntityName: "DM",
                in: context
            )!

            let DMModel = DM(
                entity: entityDescription,
                insertInto: context
            )
            
            let data = dataArray[0] as! [String: Any]
            let receiverId = data["receiverId"]
            let senderId = data["senderId"]

            DMModel.username = data["username"] as? String
            DMModel.message = data["message"] as? String
            DMModel.date = data["date"] as? String
            DMModel.id = Int64(self.getDMId(receiver: receiverId as! Int, sender: senderId as! Int) + 1)
            DMModel.senderId = Int64("\(String(describing: senderId!))")!
            DMModel.receiverId = Int64("\(String(describing: receiverId!))")!
            print("zapisuje")
            
            /// -----------------------------------------------------
            
            let currentAccount = self.client.getCurrentAccount()
            var chatId: Int64
                    
            if(DMModel.receiverId == currentAccount.userId) { chatId = DMModel.senderId }
            else { chatId = DMModel.receiverId }
            
            self.sortChats(chatId: chatId)

            completion(DMModel)
            
            try! context.save()
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
            
            self.socket.emit("get_information_about_account", Int(newChatModel.chatId))

            self.socket.on("get_information_about_account") { dataArray, socketAck in
                let data = dataArray[0] as! [String: Any]
                newChatModel.name = data["username"] as? String
                //model.avatar = data["avatar"] as? String
                //print(model.avatar)
                chats = chats.sorted { $0.id > $1.id }
                try! context.save()
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
        
    func getDMId(receiver: Int, sender: Int) -> Int {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
        let messages = try! context.fetch(fetchRequest) as! [DM]

        var messageId: Int = 0
        if(messages != []) {
            for message in messages {
                if(message.receiverId == receiver && message.senderId == sender || message.receiverId == sender && message.senderId == receiver) {
                    messageId+=1
                }
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
        
        print("+++++++++++")
        print(chat)
        print("+++++++++++")
        
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
