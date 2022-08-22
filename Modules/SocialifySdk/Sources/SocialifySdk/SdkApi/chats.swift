//
//  chats.swift
//  chats
//
//  Created by Tomasz on 17/10/2021.
//

import Foundation
import CoreData
import SwiftUI

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func fetchChats() -> FetchedResults<Chat> {
        let userId = self.getCurrentAccount()
        
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Chat.id,
                ascending: true)
        ]
        request.predicate = NSPredicate(format: "userId == %@", userId as! CVarArg)
        
        var fetchRequest = FetchRequest<Chat>(fetchRequest: request)
        var chats: FetchedResults<Chat> { fetchRequest.wrappedValue }
        
        return chats
        
//        let messages = self.fetchLastMessages()
//        let dms = self.fetchLastDMs()
//        let context = self.persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
//        var chats = try! context.fetch(fetchRequest) as! [Chat]
//        chats = chats.sorted { $0.id < $1.id }
//
//        var readyChats = []
//
//        for chat in chats {
//            if (chat.type == "Room") {
//                for message in messages {
//                    if (message.room == chat.chatId) {
//                        readyChats.append([
//                            "type": "Room",
//                            "chatId": message.room,
//                            "userId": chat.userId,
//                            "avatar": chat.avatar,
//                            "lastMessage": message,
//                            "name": chat.name,
//                            ""
//                        ])
//                    }
//                }
//            }
//        }
    }
        
    private func fetchLastDMs() -> [FetchedResults<DM>] {
        let chats = self.fetchChats()
        var dms: [FetchedResults<DM>] = []
        
        for chat in chats {
            if(chat.type != "Room") {
                dms.append(self.fetchLastLiveDM(receiver: chat.chatId!))
            }
        }
        
        return dms
    }
    
//    private func fetchLastMessages() -> [FetchedResults<Message>] {
//        let rooms = self.fetchRooms()
//        var messages: [FetchedResults<Message>] = []
//
//        for room in rooms {
//            messages.append(self.fetchLastLiveMessageForRoom(roomId: room.roomId as! Int))
//        }
//
//        return messages
//    }
    
    public func fetchLastLiveDM(receiver: String) -> FetchedResults<DM> {
        let request: NSFetchRequest<DM> = DM.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \DM.id,
                ascending: false)
        ]
        
        let predicateForReceivedMessageReceived = NSPredicate(format: "receiverId == %@", NSString(string: self.getCurrentAccount().userId!))
        let predicateForSendMessageReceived = NSPredicate(format: "receiverId == %@", NSString(string: receiver))
        let predicateForSendMessageSend = NSPredicate(format: "senderId == %@", NSString(string: self.getCurrentAccount().userId!))
        let predicateForReceivedMessageSend = NSPredicate(format: "senderId == %@", NSString(string: receiver))
        
        let predicateAndReceived = NSCompoundPredicate(type: .and, subpredicates: [predicateForReceivedMessageSend, predicateForReceivedMessageReceived])
        let predicateAndSend = NSCompoundPredicate(type: .and, subpredicates: [predicateForSendMessageSend, predicateForSendMessageReceived])
        
        let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateAndSend, predicateAndReceived])
        
        request.predicate = finalPredicate
        
        var fetchRequest = FetchRequest<DM>(fetchRequest: request)
        var dm: FetchedResults<DM> { fetchRequest.wrappedValue }
        
        return dm
    }
    
    public func fetchLastLiveMessageForRoom(roomId: Int) -> FetchedResults<Message> {
//        let request: FetchRequest<Message> = Message.fetchRequest()
//        request.fetchLimit = 1
//        request.sortDescriptors = [
//            NSSortDescriptor(
//                keyPath: \Message.id,
//                ascending: false)
//        ]
//        request.predicate = NSPredicate(format: "room == %@", NSNumber(value: roomId))
        
        var fetchRequest: FetchRequest<Message>
        var messages: FetchedResults<Message> { fetchRequest.wrappedValue }
        
        fetchRequest = FetchRequest(
            entity: Message.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Message.id,
                    ascending: false)
            ],
            predicate: NSPredicate(format: "room == %@", NSNumber(value: roomId))
        )
        
        return messages
    }
}
