//
//  registerDevice.swift
//
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation
import SwiftyRSA
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
                    let serverPublicKey = value.0
                    let privateKey = generatePrivateKey()
                    let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: serverPublicKey)
                    
                    let encrypted = try! encrypt(text: password, symmetricKey: symmetricKey)
                    
                    let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/newDevice")!
                    
                    let encryptedCiphertext = encrypted.ciphertext.base64EncodedString()
                    let encryptedTag = encrypted.tag.base64EncodedString()
                    let nonceBytes = encrypted.nonce.withUnsafeBytes { Data(Array($0)) }
                    let nonceData = Data(bytes: nonceBytes)
                    let nonce = nonceData.withUnsafeBytes {
                                        (pointer: UnsafePointer<Int8>) -> [Int8] in
                        let buffer = UnsafeBufferPointer(start: pointer,
                                                         count: nonceData.count)
                        return Array<Int8>(buffer)
                    }
                    
                    let encryptedPassword = try! encrypted.combined!
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    
                    
                    
                    
                    
                    let keys = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
                    let signKey = P256.Signing.PrivateKey()
                    let pubKey = signKey.publicKey
                    
                    print(signKey.pemRepresentation)
                    
                    let payload: [String: Any] = [
                        "username": username,
                        "password": encryptedPassword.base64EncodedString().dropFirst(16),
                        "pubKey": value.1, // 1 means public key as string
                        "clientPubKey": privateKey.publicKey.pemRepresentation,
                        "nonce": nonce,
                        "device": [
                            "deviceName": "\(self.deviceModel) - \(self.systemVersion)",
                            "timestamp": "\(Int(NSDate().timeIntervalSince1970))",
                            "appVersion": self.LIBRARY_VERSION,
                            "os": self.systemVersion,
                            "signPubKey": pubKey.pemRepresentation
                        ]
                    ]
                    
                    let jsonPayload = try? JSONSerialization.data(withJSONObject: payload)
                    
                    request.httpBody = jsonPayload
                    
                    let timestamp = NSDate().timeIntervalSince1970
                    let authToken = self.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "newDevice")
                    
                    request.addValue(authToken ?? "", forHTTPHeaderField: "AuthToken")
                    
                    self.request(request: request, timestamp: timestamp) { value in
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
                            model.deviceId = "\(response["data"]["deviceId"])"
                            model.userId = "\(response["data"]["userId"])"
                            model.isCurrentAccount = true
                            
                            let accounts = self.fetchAccounts()
                            
                            var accountId: Int64 = 0 as Int64
                            
                            if(accounts != []) {
                                accountId = accounts[accounts.count-1].value(forKey: "id") as! Int64 + 1
                            }
                            
                            model.id = accountId
                            
                            for account in accounts {
                                if(account.isCurrentAccount) {
                                    account.isCurrentAccount = false
                                }
                            }
                            
                            model.isCurrentAccount = true
                            
                            do {
                                try context.save()
                            } catch { completion(.failure(SdkError.SavingContextError)) }
                            
                            self.keychain["\(accountId)-privateKey"] = signKey.pemRepresentation
                           
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
