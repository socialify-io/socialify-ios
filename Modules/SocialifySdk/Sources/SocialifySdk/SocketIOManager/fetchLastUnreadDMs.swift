//
//  fetchLastUnreadDMs.swift
//  
//
//  Created by Tomasz on 30/01/2022.
//

import Foundation
import CoreData
import CryptoKit

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func fetchLastUnreadDMs() {
        let context = self.client.persistentContainer.viewContext
        
        socket.emit("fetch_last_unread_dms")
        socket.on("fetch_last_unread_dms") { dataArray, socketAck in
            let data = dataArray[0] as! [[String: Any]]

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
            let currentAccount = self.client.getCurrentAccount()

            for dm in data {
                fetchRequest.predicate = NSPredicate(format: "chatId == %@", dm["sender"] as! CVarArg)
                var chat = try! context.fetch(fetchRequest) as! [Chat]
                
                let receiverId: String = "\(dm["receiver"] ?? "")"
                let senderId: String = "\(dm["sender"] ?? "")"
                
                var privateKeyPem = ""
                
                print("AAĄĄĄĄĄAASAWDAWDAWDAWDAWDW")
                print(chat)
                print("AAĄĄĄĄĄAASAWDAWDAWDAWDAWDW")

                if(chat != []) {
                    
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//                    let date = dateFormatter.date(from: "\(dm["date"]!)")
//
//                    chat[0].lastMessageId = dm["id"] as! Int64
//                    chat[0].lastMessage = dm["message"] as? String
//                    chat[0].isRead = false
//                    chat[0].date = date
//                    chat[0].lastMessageAuthor = dm["username"] as? String
//
//                    try! context.save()
                    
                    
                    print("JEST CHAT")
                    privateKeyPem = self.client.keychain["\(senderId)-e2ePrivateKey"]!
                } else {
                    privateKeyPem = self.client.keychain["\(currentAccount.id)-e2ePublicKey"]!
                    print("NIE MA CHATU")
//                    let newE2EPrivateKey = generatePrivateKey()
//                    let e2ePublicKeyPem = newE2EPrivateKey.publicKey.pemRepresentation
//                    self.socket.emit("update_public_e2e_key", ["key": e2ePublicKeyPem])
//                    self.socket.on("update_public_e2e_key") {_,_ in
//                        self.client.keychain["\(currentAccount.id)-e2ePublicKey"] = newE2EPrivateKey.pemRepresentation
//                        self.socket.off("update_public_e2e_key")
//                    }
                    self.client.keychain["\(senderId)-e2ePrivateKey"] = privateKeyPem
                }
                    
                let privateKey = try! P256.KeyAgreement.PrivateKey(pemRepresentation: privateKeyPem)
                
                let senderDeviceId: String = dm["deviceId"] as! String
               
                let context = self.client.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "E2EKey")
                fetchRequest.predicate = NSPredicate(format: "deviceId == %@", NSString(string: senderDeviceId))
                let fetchResults = try! context.fetch(fetchRequest) as! [E2EKey]
                
                let publicKeyPem = dm["senderNewPublicKey"] as! String
                
                let publicKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: publicKeyPem)
                let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: publicKey)
            
                var encryptedMessage: [String: String] = [:]
                
                for message in dm["message"] as! [[String: String]] {
                    if (message["deviceId"] == currentAccount.deviceId) {
                        encryptedMessage = message
                    }
                }
                
                if (encryptedMessage != [:]) {
                    let ciphertextRaw: String = encryptedMessage["ciphertext"]!
                    let nonceRaw: String = encryptedMessage["nonce"]!
                    let tagRaw: String = encryptedMessage["tag"]!
                    
                    let ciphertext = Data(base64Encoded: ciphertextRaw)
                    let nonce = Data(hexString: "\(nonceRaw)")
                    let tag = Data(hexString: "\(tagRaw)")
                    
                    let sealedBox = try! AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce!),
                                                           ciphertext: ciphertext!,
                                                           tag: tag!)
                    
                    let decryptedData = try! AES.GCM.open(sealedBox, using: symmetricKey)
                    let decryptedMessage = String(decoding: decryptedData, as: UTF8.self)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let date = dateFormatter.date(from: "\(dm["date"]!)")
                    
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "DM",
                        in: context
                    )!
                    
                    let DMModel = DM(
                        entity: entityDescription,
                        insertInto: context
                    )
                    
                    DMModel.username = dm["username"] as? String
                    DMModel.message = decryptedMessage as? String
                    DMModel.date = date
                    DMModel.id = dm["id"] as? String
                    DMModel.senderId = senderId
                    DMModel.receiverId = receiverId
                    DMModel.isRead = true
                    
                    print("DMMODEL TUTAJ JEST HALOOOO")
                    print(DMModel)
                    print("DMMODEL TUTAJ JEST HALOOOO")
                    
                    let media = dm["media"] as! [[String: Any]]
                        
                    for mediaElement in media {
                        let entityDescription = NSEntityDescription.entity(
                            forEntityName: "Media",
                            in: context
                        )!

                        let MediaModel = Media(
                            entity: entityDescription,
                            insertInto: context
                        )
                        
                        MediaModel.chatId = senderId as! String
                        MediaModel.type = mediaElement["type"] as! Int16
                        MediaModel.messageId = DMModel.id as! String
                        MediaModel.url = mediaElement["mediaURL"] as! String
                    }
                    
                    let fetchRequestForE2EKey = NSFetchRequest<NSFetchRequestResult>(entityName: "E2EKey")
                    fetchRequestForE2EKey.predicate = NSPredicate(format: "deviceId == %@", NSString(string: senderDeviceId))
                    let fetchResultsForE2EKey = try! context.fetch(fetchRequest) as! [E2EKey]
                    
                    if(fetchResults == []) {
                        let entityDescription = NSEntityDescription.entity(
                            forEntityName: "E2EKey",
                            in: context
                        )!
                                
                        let model = E2EKey(
                            entity: entityDescription,
                            insertInto: context
                        )
                        
                        model.key = dm["senderNewPublicKey"] as! String
                        model.userId = senderId as! String
                        model.deviceId = senderDeviceId as! String
                        model.dmId = dm["id"] as! String
                        
                        try! context.save()
                    } else {
                        let idInSavedKey: String = fetchResultsForE2EKey[0].dmId!
                        if ("\(dm["id"])" > idInSavedKey) {
                            fetchResultsForE2EKey[0].key = dm["senderNewPublicKey"] as! String
                        }
                        
                        try! context.save()
                    }
                    
                    try! context.save()
                    
                    self.sortChats(chatId: senderId)
                }
               
                self.socket.off("fetch_last_unread_dms")
            }
        }
    }
}
