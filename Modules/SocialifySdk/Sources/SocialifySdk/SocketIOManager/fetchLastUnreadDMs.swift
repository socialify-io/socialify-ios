//
//  fetchLastUnreadDMs.swift
//  
//
//  Created by Tomasz on 30/01/2022.
//

import Foundation
import CoreData

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func fetchLastUnreadDMs() {
        socket.emit("fetch_last_unread_dms")
    }
    
//    public func getFetchLastUnreadDMsResponse() {
//        let context = self.client.persistentContainer.viewContext
//
//        socket.on("fetch_last_unread_dms") { dataArray, socketAck in
//            let data = dataArray[0] as! [[String: Any]]
//
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
//
//            for dm in data {
//                fetchRequest.predicate = NSPredicate(format: "chatId == %@", NSNumber(value: Int("\(dm["sender"] ?? "")")!))
//                var chat = try! context.fetch(fetchRequest) as! [Chat]
//
//                if(chat != []) {
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//                    let date = dateFormatter.date(from: "\(dm["date"]!)")
//
//                    chat[0].lastMessageId = dm["id"] as! Int64
//                    chat[0].lastMessage = dm["message"] as? String
//                    chat[0].isRead = false
//                    chat[0].date = date
//                    chat[0].lastMessageAuthor = dm["username"] as? String
//
//                    try! context.save()
//                }
//            }
//        }
//    }
}
