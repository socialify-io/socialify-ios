//
//  room.swift
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
import SwiftUI

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    public func getRoomById(roomId: Int) -> Room {
        let context = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Room")
        fetchRequest.predicate = NSPredicate(format: "roomId == %@", NSNumber(value: roomId))
        var room = try! context.fetch(fetchRequest) as! [Room]
        
        return room[0]
    }
}

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func createRoom(roomName: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.emit("create_room", ["roomName": roomName, "password": password])
        socket.on("create_room") { dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            
            if((resp["success"] != nil) == true) {
                let data = resp["data"] as! [String: Int]
                let roomId = data["roomId"]!
                self.addRoomToDB(roomId: roomId, roomName: roomName)
               
                completion(.success(true))
            } else {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
        }
    }
    
    public func sendMessage(roomId: Int, message: String) {
        socket.emit("send_message", ["roomId": roomId, "message": message])
    }
    
    public func connectRoom(roomId: Int) {
        socket.emit("connect_room", ["roomId": roomId])
        socket.on("send_message") { dataArray, socketAck in
            let context = self.client.persistentContainer.viewContext
            
            let data = dataArray[0] as! [String: Any]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
            fetchRequest.predicate = NSPredicate(format: "id == %@", data["id"] as! CVarArg)
            let allMessagesWithSameId = try! context.fetch(fetchRequest) as! [Message]
            
            if (allMessagesWithSameId == []) {
                let entityDescription = NSEntityDescription.entity(
                    forEntityName: "Message",
                    in: context
                )!

                let MessageModel = Message(
                    entity: entityDescription,
                    insertInto: context
                )
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                fetchRequest.predicate = NSPredicate(format: "room == %@", NSDecimalNumber(value: roomId))
                fetchRequest.sortDescriptors = [NSSortDescriptor(
                                                keyPath: \Message.id,
                                                ascending: true)]
                
                var messages = try! context.fetch(fetchRequest) as! [Message]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: "\(data["date"]!)")

                MessageModel.username = data["username"] as? String
                MessageModel.message = data["message"] as? String
                MessageModel.date = date
                MessageModel.id = NSDecimalNumber(value: data["id"] as! Int)
                MessageModel.room = NSDecimalNumber(value: roomId)
                MessageModel.sender = NSDecimalNumber(value: data["sender"] as! Int)
                
                try! context.save()
            }
        }
    }
    
    private func addRoomToDB(roomId: Int, roomName: String) {
        let context = self.client.persistentContainer.viewContext
        
        let roomEntityDescription = NSEntityDescription.entity(
            forEntityName: "Room",
            in: context
        )!
        
        let chatEntityDescription = NSEntityDescription.entity(
            forEntityName: "Chat",
            in: context
        )!
        
        
        let roomModel = Room(
            entity: roomEntityDescription,
            insertInto: context
        )
        
        let chatModel = Chat(
            entity: chatEntityDescription,
            insertInto: context
        )
        
        roomModel.roomId = NSDecimalNumber(value: roomId)
        roomModel.name = roomName
      
        let datenow = Date()

        chatModel.lastMessage = "Created \(roomName) room"
        chatModel.lastMessageId = -1
        chatModel.date = datenow
        chatModel.isRead = true
        chatModel.type = "Room"
        chatModel.chatId = Int64(roomId)
        chatModel.name = roomName
        
        try! context.save()
    }
}
