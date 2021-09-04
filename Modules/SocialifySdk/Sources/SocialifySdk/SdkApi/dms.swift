//
//  dms.swift
//  dms
//
//  Created by Tomasz on 04/09/2021.
//

import Foundation
import CoreData

@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func lastDMtoUser(dm: LastDM) -> User {
        let currentAccount = getCurrentAccount()
        var id: Int64 = 0 as Int64
        
        if(currentAccount.userId == dm.receiverId) {
            id = dm.userId
        } else {
            id = dm.receiverId
        }
        
        let context = self.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "User",
            in: context
        )!
        
        let model = User(
            entity: entityDescription,
            insertInto: context
        )
        
        model.id = id
        model.username = dm.username
        model.avatar = dm.avatar
        
        return model
    }
}
