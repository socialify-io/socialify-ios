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
    public func getRoomById(roomId: String) -> Room {
        let context = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Room")
        fetchRequest.predicate = NSPredicate(format: "roomId == %@", NSString(string: roomId))
        var room = try! context.fetch(fetchRequest) as! [Room]
        
        return room[0]
    }
}

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
   
    public func listenForMessages(completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.on("send_message") { dataArray, socketAck in
            let context = self.client.persistentContainer.viewContext
            
            let data = dataArray[0] as! [String: Any]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
            fetchRequest.predicate = NSPredicate(format: "id == %@", data["id"] as! CVarArg)
            let allMessagesWithSameId = try! context.fetch(fetchRequest) as! [Message]
          
            print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa")
            print(data)
            print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa")
            
            if (allMessagesWithSameId == []) {
                let entityDescription = NSEntityDescription.entity(
                    forEntityName: "Message",
                    in: context
                )!

                let MessageModel = Message(
                    entity: entityDescription,
                    insertInto: context
                )
                
//                print("dupadupadupadupadupaduapduapduapduapda")
//                print(Int(data["roomId"]!))
//                print("dupadupadupadupadupaduapduapduapduapda")
//
                let roomId: String = data["roomId"] as! String //Int((data["roomId"] as! NSString).floatValue)
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                fetchRequest.predicate = NSPredicate(format: "room == %@", roomId as! CVarArg)
                fetchRequest.sortDescriptors = [NSSortDescriptor(
                                                keyPath: \Message.id,
                                                ascending: true)]
                
                var messages = try! context.fetch(fetchRequest) as! [Message]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: "\(data["date"]!)")

                let isSystemNotification: Bool = data["is_system_notification"]! as! Bool
                print(isSystemNotification)
                
                MessageModel.username = data["username"] as? String
                MessageModel.message = data["message"] as? String
                MessageModel.date = date
                MessageModel.id = data["id"] as! String
                MessageModel.room = roomId as! String
                MessageModel.isSystemNotification = isSystemNotification
                
                if(isSystemNotification) {
                    MessageModel.sender = nil
                } else {
                    MessageModel.sender = data["sender"] as! String
                }
                
                try! context.save()
            }
        }
    }
    
    public func createRoom(roomName: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.emit("create_room", ["roomName": roomName, "password": password])
        socket.on("create_room") { dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            
            if((resp["success"] != nil) == true) {
                let data = resp["data"] as! [String: String]
                let roomId = data["roomId"]!

                self.addRoomToDB(roomId: roomId, roomName: roomName)
                
                self.connectRoom(roomId: roomId)
                self.socket.emit("activate_room", ["roomId": roomId])
                
                completion(.success(true))
            } else {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
        }
    }
    
    public func joinRoom(roomId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.emit("join_to_room", ["roomId": roomId])
        socket.on("join_to_room") { dataArray, socketAck in
            print("UTklGHJGHbv,J KLHJKLuGH JKLvKGH JKLGH JKLGH JKLGH JKLGH JKL")
            print(dataArray[0])
            print("UTklGHJGHbv,J KLHJKLuGH JKLvKGH JKLGH JKLGH JKLGH JKLGH JKL")
            let resp: [String: Any?] = dataArray[0] as! [String: Any?]
            
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            print(resp)
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            
            if((resp["success"] != nil) == true) {
                let data = resp["data"] as! [String: String]

                self.addRoomToDB(roomId: roomId, roomName: data["roomName"] ?? "<Room name couldn't be loaded>")
                
                self.connectRoom(roomId: roomId)
                completion(.success(true))
            } else {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
        }
    }
    
    public func getInfoAboutRoom(roomId: String, completion: @escaping (Result<SocialifyClient.InfoAboutRoom, Error>) -> Void) {
        socket.emit("get_informations_about_room", ["roomId": roomId])
        socket.on("get_informations_about_room") { dataArray, socketAck in
            let data = dataArray[0] as! [String: Any]
            
            print("ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą")
            print(data["roomMembers"])
            print("ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą")
            
            let roomInfoModel = SocialifyClient.InfoAboutRoom(
                roomId: data["roomId"] as! String,
                isPublic: (data["isPublic"] != nil),
                roomName: data["roomName"] as! String,
                roomMembers: data["roomMembers"] as! [[String : Any]]
            )
            
            completion(.success(roomInfoModel))
        }
    }
    
    public func sendMessage(roomId: String, message: String) {
        socket.emit("send_message", ["roomId": roomId, "message": message])
    }
    
    public func connectRoom(roomId: String) {
        socket.emit("connect_room", ["roomId": roomId])
//        socket.on("send_message") { dataArray, socketAck in
//            let context = self.client.persistentContainer.viewContext
//
//            let data = dataArray[0] as! [String: Any]
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//            fetchRequest.predicate = NSPredicate(format: "id == %@", data["id"] as! CVarArg)
//            let allMessagesWithSameId = try! context.fetch(fetchRequest) as! [Message]
//
//            print(data)
//
//            if (allMessagesWithSameId == []) {
//                let entityDescription = NSEntityDescription.entity(
//                    forEntityName: "Message",
//                    in: context
//                )!
//
//                let MessageModel = Message(
//                    entity: entityDescription,
//                    insertInto: context
//                )
//
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//                fetchRequest.predicate = NSPredicate(format: "room == %@", NSDecimalNumber(value: roomId))
//                fetchRequest.sortDescriptors = [NSSortDescriptor(
//                                                keyPath: \Message.id,
//                                                ascending: true)]
//
//                var messages = try! context.fetch(fetchRequest) as! [Message]
//
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//                let date = dateFormatter.date(from: "\(data["date"]!)")
//
//                let isSystemNotification: Bool = data["is_system_notification"]! as! Bool
//                print(isSystemNotification)
//
//                MessageModel.username = data["username"] as? String
//                MessageModel.message = data["message"] as? String
//                MessageModel.date = date
//                MessageModel.id = NSDecimalNumber(value: data["id"] as! Int)
//                MessageModel.room = NSDecimalNumber(value: data["roomId"] as! Int)
//                MessageModel.isSystemNotification = isSystemNotification
//
//                if(isSystemNotification) {
//                    MessageModel.sender = nil
//                } else {
//                    MessageModel.sender = NSDecimalNumber(value: data["sender"] as! Int)
//                }
//
//                try! context.save()
//            }
//        }
    }
    
    private func addRoomToDB(roomId: String, roomName: String) {
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
        
        roomModel.roomId = roomId as! String
        roomModel.name = roomName
      
        let datenow = Date()

        chatModel.type = "Room"
        chatModel.chatId = "\(roomId)" as! String
        chatModel.name = roomName
        
        try! context.save()
    }
}
