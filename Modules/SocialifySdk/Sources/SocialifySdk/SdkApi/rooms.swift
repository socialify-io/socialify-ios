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
    
    public func fetchRooms() -> [Room] {
        let context = self.persistentContainer.viewContext
        return getRoomsFromCoreData(context: context)
    }
    
    private func getRoomsFromCoreData(context: NSManagedObjectContext) -> [Room] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Room")
        let rooms = try! context.fetch(fetchRequest) as! [Room]
        return rooms.sorted { $0.id < $1.id }
    }
}
