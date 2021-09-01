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
            let context = self.client.persistentContainer.viewContext

            let entityDescription = NSEntityDescription.entity(
                forEntityName: "DM",
                in: context
            )!

            let model = DM(
                entity: entityDescription,
                insertInto: context
            )
            
            let data = dataArray[0] as! [String: Any]
            let receiverId = data["receiverId"]
            let senderId = data["senderId"]

            model.username = data["username"] as? String
            model.message = data["message"] as? String
            model.date = data["date"] as? String
            model.id = Int64(self.getLastDMId(receiverId: receiverId as! Int, senderId: senderId as! Int) + 1)
            model.senderId = Int64("\(String(describing: senderId!))")!
            model.receiverId = Int64("\(String(describing: receiverId!))")!
            
            self.setLastDM(receivedDM: model)
            
            try! context.save()
            
            completion(model)
        }
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
    
    public func getLastDMs() -> [LastDM] {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastDM")
        let dms = try! context.fetch(fetchRequest) as! [LastDM]
        
        let currentAccount = client.getCurrentAccount()
        
        var lastDMsForUser: [LastDM] = []
        for dm in dms {
            if(dm.userId == currentAccount.id) {
                lastDMsForUser.append(dm)
            }
        }
        
        return lastDMsForUser.sorted { $0.id < $1.id }
    }
    
    private func getLastDMId(receiverId: Int, senderId: Int) -> Int {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
        let messages = try! context.fetch(fetchRequest) as! [DM]
        
        var messageId: Int = 0
        if(messages != []) {
            for message in messages {
                if(message.receiverId == receiverId && message.senderId == senderId || message.receiverId == senderId && message.senderId == receiverId) {
                    messageId+=1
                }
            }
        }
        return messageId
    }
    
    private func setLastDM(receivedDM: DM) {
        let context = client.persistentContainer.viewContext
        let currentAccount = client.getCurrentAccount()
        var dms = getLastDMs()
        
        var userId: Int64
        
        if(receivedDM.receiverId == currentAccount.userId) { userId = receivedDM.senderId }
        else { userId = receivedDM.receiverId }
        
        if(isReceiverIdInDB(receiverId: userId)) {
            for dm in dms {
                if(dm.receiverId == userId) {
                    dm.id = 0
                } else {
                    dm.id += 1
                }
            }
            
            dms = dms.sorted { $0.id > $1.id }
            try! context.save()
        } else {
            let entityDescription = NSEntityDescription.entity(
                forEntityName: "LastDM",
                in: context
            )!
                    
            let model = LastDM(
                entity: entityDescription,
                insertInto: context
            )
            
            for dm in dms {
                dm.id += 1
            }
            
            model.userId = currentAccount.id
            model.receiverId = userId
            model.id = 0 as Int64
            
            let url = URL(string: "\(client.API_ROUTE)v\(client.API_VERSION)/getInformationAboutAccount")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let payload: [String: Any] = [
                "userId": userId
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
            
            DispatchQueue.main.async { [self] in
                client.request(request: request, authTokenHeader: "getInformationAboutAccount") { value in
                    switch value {
                    case .success(let response):
                        model.username = response["data"]["username"].stringValue
                        model.avatar = response["data"]["avatar"].stringValue
                        
                        dms = dms.sorted { $0.id > $1.id }
                        try! context.save()
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    private func isReceiverIdInDB(receiverId: Int64) -> Bool {
        let dms = getLastDMs()
        
        for dm in dms {
            if(dm.receiverId == receiverId) {
                return true
            }
        }
        
        return false
    }
}
