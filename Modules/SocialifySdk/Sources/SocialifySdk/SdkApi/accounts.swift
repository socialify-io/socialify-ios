//
//  accounts.swift
//
//
//  Created by Tomasz on 06/08/2021.
//

import Foundation
import CoreData

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Getting accounts from Core Data
    
    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) {
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let accounts = try! context.fetch(fetchRequest) as! [Account]
        
        var response: [Account] = []

        for account in accounts as [Account] {
            response.append(account)
        }
        
        completion(.success(response))
    }
}
