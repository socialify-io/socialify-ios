//
//  chats.swift
//  chats
//
//  Created by Tomasz on 17/10/2021.
//

import Foundation
import CoreData

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func fetchChats() -> [Chat] {
        let context = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let chats = try! context.fetch(fetchRequest) as! [Chat]
        return chats.sorted { $0.id < $1.id }
    }
    
    
}
