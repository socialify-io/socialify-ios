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
}
