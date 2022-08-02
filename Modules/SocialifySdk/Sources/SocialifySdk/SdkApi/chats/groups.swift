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
import Network

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    public func getGroupById(groupId: String) -> ChatGroup {
        let context = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatGroup")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSString(string: groupId))
        var group = try! context.fetch(fetchRequest) as! [ChatGroup]
        
        return group[0]
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
            fetchRequest.predicate = NSPredicate(format: "id == %@", data["_id"] as! CVarArg)
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
                
                let groupId: String = data["group"] as! String //Int((data["roomId"] as! NSString).floatValue)
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                fetchRequest.predicate = NSPredicate(format: "group == %@", groupId as! CVarArg)
                fetchRequest.sortDescriptors = [NSSortDescriptor(
                                                keyPath: \Message.id,
                                                ascending: true)]
                
                var messages = try! context.fetch(fetchRequest) as! [Message]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: "\(data["timestamp"]!)")

                let isSystemNotification: Bool = data["isSystemNotification"]! as! Bool
                print(isSystemNotification)
                
                MessageModel.username = data["username"] as? String
                MessageModel.message = data["message"] as? String
                MessageModel.date = date
                MessageModel.id = data["_id"] as! String
                MessageModel.group = groupId
                MessageModel.room = data["room"] as! String
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
    
    public func createGroup(groupName: String, groupDescription: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.emit("create_group", ["name": groupName, "description": groupDescription])
        socket.on("create_group") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
           
            let success: Bool = resp["success"] as! Bool
            if(success) {
                
                let data = resp["data"] as! [String: String]
                let groupId = data["groupId"]!

                self.addGroupToDB(groupId: groupId, groupName: groupName, groupDescription: groupDescription)
                
//                self.connectRoom(roomId: roomId)
//                self.socket.emit("activate_room", ["roomId": roomId])
                socket.off("create_group")
                completion(.success(true))
            } else {
                socket.off("create_group")
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
        }
    }
    
    public func joinGroup(linkId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.emit("join_group", ["linkId": linkId])
        socket.on("join_group") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("join_group")
           
            let success: Bool = resp["success"] as! Bool
            if(success) {
                let data = resp["data"] as! [String: String]
                let groupId = data["groupId"]!
                let groupName = data["groupName"]!
                let groupDescription = data["groupDescription"]!

                self.addGroupToDB(groupId: groupId, groupName: groupName, groupDescription: groupDescription)
                
                completion(.success(true))
            } else {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
        }
    }
    
    public func createInviteLink(groupId: String,
                                 linkName: String?,
                                 isAdminApprovalNeeded: Bool,
                                 isUnlimitedUses: Bool,
                                 isExpiryDateSet: Bool,
                                 numberOfUses: String?,
                                 expiryDate: Date?,
                                 completion: @escaping (Result<Bool, Error>) -> Void) {
        let dateFormatter = ISO8601DateFormatter()
        
        let date: String = dateFormatter.string(from: expiryDate!)
        
        let payload: [String: Any] = [
            "groupId": groupId,
            "linkName": linkName,
            "isAdminApprovalNeeded": isAdminApprovalNeeded,
            "isUnlimitedUses": isUnlimitedUses,
            "isExpiryDateSet": isExpiryDateSet,
            "uses": numberOfUses,
            "expiryDate": date,
            "isForSpecialUsers": false,
            "specialUsers": []
        ]
        
        socket.emit("create_invite_link", payload)
        socket.on("create_invite_link") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            
            print("==============LINK CREATION RESPONSE================")
            print(resp)
            print("==============LINK CREATION RESPONSE================")
            socket.off("create_invite_link")
            let success: Bool = (resp["success"] != nil)
            
            if(success) {
                completion(.success(true))
            } else {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
        }
    }

    public func getInviteLinks(groupId: String, completion: @escaping (Result<[SocialifyClient.GroupLink], Error>) -> Void) {
        socket.emit("get_invite_links", ["groupId": groupId])
        socket.on("get_invite_links") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            let data = resp["data"] as! [String: Any]
            let links = data["links"] as! [[String: Any?]]
            
            let response = links.map { link in
                SocialifyClient.GroupLink(
                    id: link["id"] as! String,
                    linkName: link["linkName"] as? String,
                    link: link["link"] as! String,
                    isUnlimitedUses: (link["isUnlimitedUses"] != nil),
                    isExpiryDateSet: (link["isExpiryDateSet"] != nil),
                    uses: link["uses"] as? Int,
                    usedTimes: link["usedTimes"] as! Int,
                    expiryDate: link["expiryDate"] as? String
                )
            }
            socket.off("get_invite_links")
            completion(.success(response))
        }
    }
    
    public func isInviteLinkInMessage(message: String, completion: @escaping ([String: Any]) -> Void) {
        let api_url = client.API_URL
        
        if (!message.contains("\(api_url)/")) {
            completion(["success": false])
            return
        }
        
        let regex = try! NSRegularExpression(pattern: "\(api_url)/[A-Za-z0-9]{16}")
        let range = NSRange(location: 0, length: message.utf16.count)
       
        let matches = regex.matches(in: message, range: range)
        let strings: [String] = matches.map { match in
            let start = message.index(message.startIndex, offsetBy: match.range.location)
            let end = message.index(start, offsetBy: match.range.length)
            return String(message[start..<end])
        }
        
        if (strings == []) {
            completion(["success": false])
            return
        }
        
        let link = strings[0]
        
        socket.emit("get_info_about_invite_link", ["link": link])
        socket.on("get_info_about_invite_link") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("get_info_about_invite_link")
            completion(resp)
            return
        }
        
        completion(["success": false])
        return
    }
    
    public func fetchRooms(groupId: String, completion: @escaping (Result<[SocialifyClient.RoomsSection], Error>) -> Void) {
        socket.emit("get_group_rooms", ["groupId": groupId])
        socket.on("get_group_rooms") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("get_group_rooms")
            let success: Bool = resp["success"] as! Bool
            
            if(!success) {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
                return
            }
            
            let data: [[String: Any]] = resp["data"] as! [[String: Any]]
            
            var sections: [SocialifyClient.RoomsSection] = []
            
            for section in data {
                let rooms: [[String: Any]] = section["rooms"] as! [[String : Any]]
                sections.append(SocialifyClient.RoomsSection(id: section["_id"] as! String,
                                                                 name: section["sectionName"] as! String,
                                                                 rooms: rooms.map({ room in
                    SocialifyClient.GroupRoom(id: room["_id"] as! String,
                                              name: room["name"] as! String,
                                              type: room["type"] as! Int)})
                ))
            }
            
            completion(.success(sections))
        }
    }
    
    public func sendMessage(groupId: String,
                             roomId: String,
                             message: String) {
        socket.emit("send_message", ["groupId": groupId,
                                     "roomId": roomId,
                                     "message": message])
    }
    
    private func addGroupToDB(groupId: String, groupName: String, groupDescription: String) {
        let context = self.client.persistentContainer.viewContext

        let groupEntityDescription = NSEntityDescription.entity(
            forEntityName: "ChatGroup",
            in: context
        )!

        let chatEntityDescription = NSEntityDescription.entity(
            forEntityName: "Chat",
            in: context
        )!


        let groupModel = ChatGroup(
            entity: groupEntityDescription,
            insertInto: context
        )

        let chatModel = Chat(
            entity: chatEntityDescription,
            insertInto: context
        )

        groupModel.id = groupId as! String
        groupModel.name = groupName
        groupModel.groupDescription = groupDescription

        let datenow = Date()

        chatModel.type = "Group"
        chatModel.chatId = "\(groupId)" as! String
        chatModel.name = groupName

        try! context.save()
    }
}
