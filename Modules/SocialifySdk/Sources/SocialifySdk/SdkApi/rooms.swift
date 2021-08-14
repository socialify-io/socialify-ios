//
//  rooms.swift
//
//
//  Created by Tomasz on 10/08/2021.
//

import Foundation
import CoreData

@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func fetchRooms() ->[Room] {
        let context = self.persistentContainer.viewContext
        return getRoomsFromCoreData(context: context)
    }
    
    private func getRoomsFromCoreData(context: NSManagedObjectContext) -> [Room] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Room")
        return try! context.fetch(fetchRequest) as! [Room]
    }
}
