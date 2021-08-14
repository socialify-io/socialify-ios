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

@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func join(roomId: String) {
        let socket = manager.defaultSocket
        
        socket.connect()

        socket.emit("join", ["room": roomId])
                    
        let context = self.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "Room",
            in: context
        )!
                
        let model = Room(
            entity: entityDescription,
            insertInto: context
        )
        
        model.roomId = roomId

        let rooms = self.fetchRooms()
    
        var id: Int64 = 0 as Int64
        
        if(rooms != []) {
            id = rooms[rooms.count-1].value(forKey: "id") as! Int64 + 1
        }
        
        model.id = id
    
        try! context.save()
    }
    
    public func send(message: String, room: Room) {
        let socket = manager.defaultSocket
        
        socket.connect()
        socket.emit("message", ["room": room.roomId, "message": message])
    }
}
