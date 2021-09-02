//
//  chats.swift
//
//
//  Created by Tomasz on 09/08/2021.
//

import Foundation
import SocketIO
import CryptoKit
import SwiftyRSA
import CoreData
import CommonCrypto
import BCryptSwift

@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func join(roomId: String) {
        socket.emit("join", ["room": roomId])
    }
    
    public func addRoom(roomId: String) {
        let context = client.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "Room",
            in: context
        )!
                
        let model = Room(
            entity: entityDescription,
            insertInto: context
        )
        
        model.roomId = roomId

        let rooms = client.fetchRooms()
        
        for room in rooms {
            room.id += 1
        }
    
        model.id = 0
    
        try! context.save()
    }
    
    public func send(message: String, room: Room) {
        socket.emit("message", ["room": room.roomId, "message": message])
    }
    
    public func getChatMessage(completion: @escaping (Message) -> Void) {
        socket.on("message") { dataArray, socketAck in
            let context = self.client.persistentContainer.viewContext

            let entityDescription = NSEntityDescription.entity(
                forEntityName: "Message",
                in: context
            )!

            let model = Message(
                entity: entityDescription,
                insertInto: context
            )

            let data = dataArray[0] as! [String: String]
            model.username = data["username"]
            model.message = data["message"]
            model.date = data["date"]
            model.id = self.getLastMessageId(roomId: data["roomId"]!) + 1
            model.userId = self.client.getCurrentAccount().id
            model.sourceId = data["roomId"]
            
            self.setLastRoom(roomId: model.sourceId ?? "")
            
            try! context.save()
            
            completion(model)
        }
    }
    
    public func getMessagesFromDB(room: Room) -> [Message] {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let messages = try! context.fetch(fetchRequest) as! [Message]
        
        let currentAccount = client.getCurrentAccount()
        
        var messagesForRoom: [Message] = []
        for message in messages {
            if(message.sourceId == room.roomId && message.userId == currentAccount.id) {
                messagesForRoom.append(message)
            }
        }
        
        return messagesForRoom.sorted { $0.id < $1.id }
    }
    
    private func setLastRoom(roomId: String) {
        let context = client.persistentContainer.viewContext
        let currentAccount = client.getCurrentAccount()
        var rooms = client.fetchRooms()
        
        for room in rooms {
            if(room.roomId == roomId) {
                room.id = 0
            } else {
                room.id += 1
            }
        }
        
        rooms = rooms.sorted { $0.id < $1.id }
        try! context.save()
    }
    
    private func getLastMessageId(roomId: String) -> Int64 {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let messages = try! context.fetch(fetchRequest) as! [Message]
        
        print(messages)
        
        var messageId: Int64 = 0 as Int64
        if(messages != []) {
            for message in messages {
                if(message.sourceId == roomId) {
                    messageId+=1
                }
            }
        }
        
        return messageId
    }
}
