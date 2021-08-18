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
    
        var id: Int64 = 0 as Int64
        
        if(rooms != []) {
            id = rooms[rooms.count-1].value(forKey: "id") as! Int64 + 1
        }
        
        model.id = id
    
        try! context.save()
    }
    
    public func send(message: String, room: Room) {
        socket.emit("message", ["room": room.roomId, "message": message])
    }
    
    public func listenForMessages() {
        socket.on("message") {_,_ in
            print("Message received")
        }
    }
}
