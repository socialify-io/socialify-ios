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
    
    public func fetchAccounts() -> [Account] {
        let context = self.persistentContainer.viewContext
        return getAccountsFromCoreData(context: context)
    }
    
    public func getCurrentAccount() -> Account {
        var currentAccount: Account?
        
        for account in fetchAccounts() {
            if(account.isCurrentAccount) {
                currentAccount =  account
            }
        }
        
        return currentAccount!
    }
    
    public func setCurrentAccount(account: Account) {
        let context = self.persistentContainer.viewContext
        let accounts = getAccountsFromCoreData(context: context)
        
        for cd_account in accounts {
            if(cd_account.isCurrentAccount) {
                cd_account.isCurrentAccount = false
            } else if(cd_account.id == account.id) {
                cd_account.isCurrentAccount = true
            }
        }
    }
    
    public func deleteAccount(account: Account) {
        let context = self.persistentContainer.viewContext
        let accounts = getAccountsFromCoreData(context: context)
        
        for cd_account in accounts {
            if(cd_account.id == account.id) {
                context.delete(cd_account)
            }
        }
        
        try! context.save()
    }
    
    private func getAccountsFromCoreData(context: NSManagedObjectContext) -> [Account] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        return try! context.fetch(fetchRequest) as! [Account]
    }
}
