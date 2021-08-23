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
    
    public func getDMMessage(completion: @escaping (Message) -> Void) {
        socket.on("send_dm") { dataArray, socketAck in
            let context = self.client.persistentContainer.viewContext

            let entityDescription = NSEntityDescription.entity(
                forEntityName: "Message",
                in: context
            )!

            let model = Message(
                entity: entityDescription,
                insertInto: context
            )

            let data = dataArray[0] as! [String: Any]
            model.id = data["id"] as! Int64
            model.username = data["username"] as? String
            model.message = data["message"] as? String
            model.date = data["date"] as? String
            
            completion(model)
        }
    }
}
