//
//  accounts.swift
//
//
//  Created by Tomasz on 06/08/2021.
//

import Foundation
import CoreData
import UIKit

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
                currentAccount = account
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
    
    public func changeBio(newBio: String) {
        let context = self.persistentContainer.viewContext
        let currentAccount = self.getCurrentAccount()
        
        currentAccount.bio = newBio
        
        try! context.save()
    }
    
    public func updateDataToDatabase(userData: [String: Any]) {
        let context = self.persistentContainer.viewContext
        let currentAccount = self.getCurrentAccount()
        
        currentAccount.username = userData["username"] as? String
        currentAccount.bio = userData["bio"] as? String
        currentAccount.avatar = Data(base64Encoded: userData["avatar"] as! String)

        try! context.save()
    }
    
    public func changeAvatar(newAvatar: String) {
        let context = self.persistentContainer.viewContext
        let currentAccount = self.getCurrentAccount()
        
        currentAccount.avatar = Data(base64Encoded: newAvatar)
        
        try! context.save()
    }
    
    
    private func getAccountsFromCoreData(context: NSManagedObjectContext) -> [Account] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        return try! context.fetch(fetchRequest) as! [Account]
    }
}

@available(iOS 14.0, *)
extension SocketIOManager {
    
    public func updateBio(bio: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        socket.emit("update_bio", ["bio": bio])
        socket.on("update_bio") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("update_bio")
            let success: Bool = resp["success"] as! Bool
            
            if(!success) {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
            }
            
            SocialifyClient.shared.changeBio(newBio: bio)
            completion(.success(true))
        }
    }
    
    public func updateAvatar(avatar: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        let imageData = avatar.pngData()
        let parsedAvatar = imageData?.base64EncodedString()
        socket.emit("upload_avatar", ["avatar": parsedAvatar])
        socket.on("upload_avatar") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("upload_avatar")
            let success: Bool = resp["success"] as! Bool
            
            if(!success) {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
                return
            }
           
            SocialifyClient.shared.changeAvatar(newAvatar: parsedAvatar!)
            completion(.success(true))
        }
    }
    
    public func updateData() {
        socket.emit("get_user_data", [])
        socket.on("get_user_data") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("get_user_data")
            let success: Bool = resp["success"] as! Bool
            
            if(!success) {
                return
            }
            
            let userData: [String: Any] = resp["user_data"] as! [String: Any]
        
            SocialifyClient.shared.updateDataToDatabase(userData: userData)
        }
    }
    
    public func searchForUser(phrase: String, completion: @escaping (Result<User, Error>) -> Void) {
        socket.emit("search_for_user", phrase)
        socket.on("search_for_user") { [self] dataArray, socketAck in
            let resp: [String: Any] = dataArray[0] as! [String: Any]
            socket.off("search_for_user")
            let success: Bool = resp["success"] as! Bool
            
            if(!success) {
                completion(.failure(SocialifyClient.SdkError.UnexpectedError))
                return
            }
            
            let userData: [String: Any] = resp["user"] as! [String: Any]
           
            let context = self.client.persistentContainer.viewContext
            
            let entityDescription = NSEntityDescription.entity(
                forEntityName: "User",
                in: context
            )!
                    
            let model = User(
                entity: entityDescription,
                insertInto: context
            )
           
            model.id = userData["_id"] as? String
            model.username = userData["username"] as? String
            model.avatarHash = userData["avatarHash"] as? String
            model.avatar = Data(base64Encoded: userData["avatar"] as! String)
            
            completion(.success(model))
        }
    }
    
    public func getUserDataById(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        let context = client.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSString(string: userId))
        let fetchResult = try! context.fetch(fetchRequest) as! [User]
        
        if(!fetchResult.isEmpty) {
            completion(.success(fetchResult[0]))
            return
        }
        
        self.socket.emit("get_information_about_account", userId)
        self.socket.on("get_information_about_account") { [self] dataArray, socketAck in
            let resp: [String: String] = dataArray[0] as! [String: String]
            socket.off("get_information_about_account")
    
            let entityDescription = NSEntityDescription.entity(
                forEntityName: "User",
                in: context
            )!
            
            let model = User(
                entity: entityDescription,
                insertInto: context
            )
            
            model.id = resp["id"] as? String
            model.username = resp["username"] as? String
            model.avatarHash = resp["avatarHash"] as? String
            model.avatar = Data(base64Encoded: resp["avatar"] as! String)
            
            try! context.save()
            
            completion(.success(model))
        }
    }
}
