//
//  registerDevice.swift
//
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation
import SwiftRSA
import SwiftUI
import CryptoKit
import SwiftUI
import CoreData

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Register new device
    
    public func registerDevice(username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.getKey() { value in
            switch value {
            case .success(let value):
                do {
                    let passwordClearText = ClearText(string: password)
                    
                    let encryptedPassword = try passwordClearText.encrypted(with: value.0, by: .rsaEncryptionOAEPSHA1).data.base64EncodedString() // 0 means model of public key
                    
                    let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/newDevice")!
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    
                    
                    var keys: [String: String] = [:]
                    
                    switch(genKeysPair()) {
                    case .success(let value):
                        keys = value
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                    let fingerprint = Insecure.SHA1.hash(data: keys["privateKey"]!.data(using: .utf8)!).hexStr
                    
                    let payload: [String: Any] = [
                        "username": username,
                        "password": encryptedPassword,
                        "pubKey": value.1, // 1 means public key as string
                        "device": [
                            "deviceName": "\(self.deviceModel) - \(self.systemVersion)",
                            "timestamp": "\(Int(NSDate().timeIntervalSince1970))",
                            "appVersion": self.LIBRARY_VERSION,
                            "os": self.systemVersion,
                            "signPubKey": keys["publicKey"],
                            "fingerprint": fingerprint
                        ]
                    ]
                    
                    let jsonPayload = try? JSONSerialization.data(withJSONObject: payload)
                    
                    request.httpBody = jsonPayload
                    
                    self.request(request: request, authTokenHeader: "newDevice") { value in
                        switch value {
                        case .success(let response):
                            let context = self.persistentContainer.viewContext
                            
                            let entityDescription = NSEntityDescription.entity(
                                forEntityName: "Account",
                                in: context
                            )!
                                    
                            let model = Account(
                                entity: entityDescription,
                                insertInto: context
                            )
                            
                            model.username = username
                            model.deviceId = Int64("\(response["data"]["id"])")!
                            model.isCurrentAccount = true

                            
                            let accounts = self.fetchAccounts()
                            
                            var accountId: Int64 = 0 as Int64
                            
                            if(accounts != []) {
                                accountId = accounts[accounts.count-1].value(forKey: "id") as! Int64 + 1
                            }
                            
                            model.id = accountId
                            
                            for account in accounts as! [Account] {
                                if(account.isCurrentAccount) {
                                    account.isCurrentAccount = false
                                }
                            }
                            
                            model.isCurrentAccount = true
                            
                            do {
                                try context.save()
                            } catch { completion(.failure(SdkError.SavingContextError)) }
                            
                            self.keychain["\(accountId)-privateKey"] = keys["privateKey"]
                            
                            completion(.success(true))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }

                } catch {
                    completion(.failure(SdkError.RSAError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
