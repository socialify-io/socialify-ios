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
