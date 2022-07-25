//
//  rooms.swift
//
//
//  Created by Tomasz on 10/08/2021.
//

import Foundation
import CoreData

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func fetchGroups() -> [ChatGroup] {
        let context = self.persistentContainer.viewContext
        return getGroupsFromCoreData(context: context)
    }
    
    private func getGroupsFromCoreData(context: NSManagedObjectContext) -> [ChatGroup] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Group")
        let groups = try! context.fetch(fetchRequest) as! [ChatGroup]
        return groups.sorted { $0.id < $1.id }
    }
}
