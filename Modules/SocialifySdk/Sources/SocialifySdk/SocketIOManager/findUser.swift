//
//  findUser.swift
//  findUser
//
//  Created by Tomasz on 22/08/2021.
//

import Foundation
import CoreData

@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func findUser(phrase: String) {
        socket.emit("find_user", phrase)
    }
    
    public func getFindUserResponse(completion: @escaping ([User]) -> Void) {
        socket.on("find_user") { dataArray, socketAck in
            let context = self.client.persistentContainer.viewContext
            var results: [User] = []
            
            let entityDescription = NSEntityDescription.entity(
                forEntityName: "User",
                in: context
            )!
            
            for user in dataArray[0] as! [[String: Any]] {
                let model = User(
                    entity: entityDescription,
                    insertInto: context
                )
                
                model.id = user["id"] as! Int64
                model.username = user["username"] as? String
                //model.avatar = String(data: user["avatar"] as! Data, encoding: .utf8)
                
                results.append(model)
            }
            
            completion(results)
        }
    }
}
