//
//  dm.swift
//  dm
//
//  Created by Tomasz on 22/08/2021.
//

import Foundation
import CoreData
import SwiftUI
import CryptoKit

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 0.1)!.base64EncodedString()
    }
}

public extension Data {
    init?(hexString: String) {
      let len = hexString.count / 2
      var data = Data(capacity: len)
      var i = hexString.startIndex
      for _ in 0..<len {
        let j = hexString.index(i, offsetBy: 2)
        let bytes = hexString[i..<j]
        if var num = UInt8(bytes, radix: 16) {
          data.append(&num, count: 1)
        } else {
          return nil
        }
        i = j
      }
      self = data
    }
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocketIOManager {
    
    public func sendDM(message: String, receiver: User, image: UIImage?) {
        var response: [[String: Any]] = []
        let newPrivateKey = generatePrivateKey()
        let context = self.client.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PendingDM")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PendingDM.id, ascending: false)]
        fetchRequest.fetchLimit = 1
        let fetchResults = try! context.fetch(fetchRequest) as! [PendingDM]
        
        var lastPendingDMId = -1
        
        if (fetchResults != []) {
            lastPendingDMId = Int(fetchResults[0].id!)
        }
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "PendingDM",
            in: context
        )!
                
        let model = PendingDM(
            entity: entityDescription,
            insertInto: context
        )
                    
        model.message = message
        model.receiverId = receiver.id
        model.id = NSDecimalNumber(string: "\(lastPendingDMId+1)")
        
        try! context.save()
        
        socket.emit("get_public_e2e_key", ["user": receiver.id])
        socket.on("get_public_e2e_key") { [self] dataArray, socketAck in
            var receiverKeys: [[String: String]] = dataArray[0] as! [[String: String]]

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "E2EKey")
            fetchRequest.predicate = NSPredicate(format: "userId == %@", NSString(string: receiver.id!))
            let fetchResults = try! context.fetch(fetchRequest) as! [E2EKey]
            
            var readyKeysToEncrypt: [[String: String]] = []
            
            for key in fetchResults {
                let toAppend: [String: String] = [
                    "publicKey": key.key!,
                    "deviceId": key.deviceId!
                ]
                
                readyKeysToEncrypt.append(toAppend)
            }
            
            let publicKeyPem = newPrivateKey.publicKey.pemRepresentation

            for key in receiverKeys {
                if (!readyKeysToEncrypt.contains(where: { $0.values.contains(key["deviceId"]!) })) {
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "E2EKey",
                        in: context
                    )!

                    let model = E2EKey(
                        entity: entityDescription,
                        insertInto: context
                    )

                    model.key = key["publicKey"]!
                    model.userId = receiver.id!
                    model.deviceId = key["deviceId"]!
                    
                    let toAppend: [String: String] = [
                        "deviceId": key["deviceId"] as! String,
                        "publicKey": key["publicKey"] as! String
                    ]
                    
                    readyKeysToEncrypt.append(toAppend)
                    
                    try! context.save()
                }
                self.socket.off("get_public_e2e_key")
            }
            
            for key in readyKeysToEncrypt {
                let receiverKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: key["publicKey"]!)
                let symmetricKey = try! deriveSymmetricKey(privateKey: newPrivateKey, publicKey: receiverKey)

                let encrypted = try! encrypt(text: message, symmetricKey: symmetricKey)
                //let encryptedContent = encrypted.combined!.base64EncodedString()

                let nonce = encrypted.nonce.withUnsafeBytes { Data(Array($0)).hexadecimal }
                let tag = encrypted.tag.hexadecimal
                let ciphertext = encrypted.ciphertext.base64EncodedString()

                let dataToAppend: [String: Any] = [
                    "receiverDeviceId": key["deviceId"],
                    "nonce": nonce,
                    "tag": tag,
                    "ciphertext": ciphertext
                ]

                response.append(dataToAppend)
            }

            if(image != nil) {
                let base64image = image?.base64

                let payload = ["receiverId": receiver.id,
                               "message": response,
                               "newPublicKey": newPrivateKey.publicKey.pemRepresentation,
                               "confirmationId": "\(lastPendingDMId+1)",
                               "media": [[
                                    "type": 1,
                                    "media": base64image
                               ]]] as [String : Any]

                socket.emit("send_dm", payload)
            } else {
                socket.emit("send_dm", ["receiverId": receiver.id,
                                        "message": response,
                                        "newPublicKey": newPrivateKey.publicKey.pemRepresentation,
                                        "confirmationId": "\(lastPendingDMId+1)",
                                        "media": []])
            }
        }
        
        
       
//        let predicateForReceiver = NSPredicate(format: "receiverId == %@", NSString(string: receiver.id!))
//        let predicateForSender = NSPredicate(format: "senderId == %@", NSString(string: self.client.getCurrentAccount().userId!))
//
//
//        let finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateForSender, predicateForReceiver])
//
//        let fetchRequestIsUserKnown = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
//        fetchRequestIsUserKnown.predicate = finalPredicate
//        let isUserKnown = try! context.fetch(fetchRequestIsUserKnown) as! [DM]
//
//        let
//
//        if (isUserKnown == []) {
//
//        }
//---------------------------------------------------------------------------
//        if (isUserKnown != []) {
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "E2EKey")
//            fetchRequest.predicate = NSPredicate(format: "userId == %@", NSString(string: receiver.id!))
//            let fetchResults = try! context.fetch(fetchRequest) as! [E2EKey]
//
//            let privateKeyPem = self.client.keychain["\(receiver.id)-e2ePrivateKey"]
//            let privateKey = try! P256.KeyAgreement.PrivateKey(pemRepresentation: privateKeyPem!)
//            let publicKeyPem = privateKey.publicKey.pemRepresentation
//
//            let newPublicKeyPem = privateKey.publicKey.pemRepresentation
//
//            for key in fetchResults {
//                let receiverKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: key.key!)
//                let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: receiverKey)
//
//                let encrypted = try! encrypt(text: message, symmetricKey: symmetricKey)
//                let encryptedContent = encrypted.combined!
//
//                let nonce = encrypted.nonce.withUnsafeBytes { Data(Array($0)).hexadecimal }
//                let tag = encrypted.tag.hexadecimal
//                let ciphertext = encrypted.ciphertext.base64EncodedString()
//
//                let dataToAppend: [String: Any] = [
//                    "receiverDeviceId": key.deviceId,
//                    "senderPublicKey": newPublicKeyPem,
//                    "nonce": nonce,
//                    "tag": tag,
//                    "ciphertext": ciphertext
//                ]
//
//                response.append(dataToAppend)
//            }
//
//
//            if(image != nil) {
//                let base64image = image?.base64
//
//                let payload = ["receiverId": receiver.id,
//                               "message": response,
//                               "newPublicKey": newPrivateKey.publicKey.pemRepresentation,
//                               "confirmationId": "\(lastPendingDMId+1)",
//                               "media": [[
//                                    "type": 1,
//                                    "media": base64image
//                               ]]] as [String : Any]
//
//                socket.emit("send_dm", payload)
//            } else {
//                socket.emit("send_dm", ["receiverId": receiver.id,
//                                        "message": response,
//                                        "newPublicKey": newPrivateKey.publicKey.pemRepresentation,
//                                        "confirmationId": "\(lastPendingDMId+1)",
//                                        "media": []])
//            }
//        } else {
//            socket.emit("get_public_e2e_key", ["user": receiver.id])
//            socket.on("get_public_e2e_key") { [self] dataArray, socketAck in
//                let receiverKeys: [[String: String]] = dataArray[0] as! [[String: String]]
//
//                let publicKeyPem = newPrivateKey.publicKey.pemRepresentation
//
//                for key in receiverKeys {
//                    let entityDescription = NSEntityDescription.entity(
//                        forEntityName: "E2EKey",
//                        in: context
//                    )!
//
//                    let model = E2EKey(
//                        entity: entityDescription,
//                        insertInto: context
//                    )
//
//                    model.key = key["publicKey"] as! String
//                    model.userId = receiver.id as! String
//                    model.deviceId = key["deviceId"] as! String
//
//                    try! context.save()
//
//                    let receiverKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: key["publicKey"]!)
//                    let symmetricKey = try! deriveSymmetricKey(privateKey: newPrivateKey, publicKey: receiverKey)
//
//                    let encrypted = try! encrypt(text: message, symmetricKey: symmetricKey)
//                    //let encryptedContent = encrypted.combined!.base64EncodedString()
//
//                    let nonce = encrypted.nonce.withUnsafeBytes { Data(Array($0)).hexadecimal }
//                    let tag = encrypted.tag.hexadecimal
//                    let ciphertext = encrypted.ciphertext.base64EncodedString()
//
//                    let dataToAppend: [String: Any] = [
//                        "receiverDeviceId": key["deviceId"],
//                        "nonce": nonce,
//                        "tag": tag,
//                        "ciphertext": ciphertext
//                    ]
//
//                    response.append(dataToAppend)
//                }
//
//                if(image != nil) {
//                    let base64image = image?.base64
//
//                    let payload = ["receiverId": receiver.id,
//                                   "message": response,
//                                   "newPublicKey": newPrivateKey.publicKey.pemRepresentation,
//                                   "confirmationId": "\(lastPendingDMId+1)",
//                                   "media": [[
//                                        "type": 1,
//                                        "media": base64image
//                                   ]]] as [String : Any]
//
//                    socket.emit("send_dm", payload)
//                } else {
//                    socket.emit("send_dm", ["receiverId": receiver.id,
//                                            "message": response,
//                                            "newPublicKey": newPrivateKey.publicKey.pemRepresentation,
//                                            "confirmationId": "\(lastPendingDMId+1)",
//                                            "media": []])
//                }
//            }
//        }
        
        self.socket.on("dm_confirmation") { [self] dataArray, socketAck in
            let data = dataArray[0] as! [String: String]
            
            if (Int(data["confirmationId"]!) == lastPendingDMId+1) {
                self.client.keychain["\(receiver.id!)-e2ePrivateKey"] = newPrivateKey.pemRepresentation
                
                let confirmationId = NSDecimalNumber(string: "\(lastPendingDMId+1)")
                
                let fetchRequestOnConfirmation = NSFetchRequest<NSFetchRequestResult>(entityName: "PendingDM")
                fetchRequestOnConfirmation.predicate = NSPredicate(format: "id == %@", confirmationId)
                let fetchResultsOnConfirmation = try! context.fetch(fetchRequestOnConfirmation) as! [PendingDM]
               
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                print(fetchResultsOnConfirmation)
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
                
                if (fetchResultsOnConfirmation != []) {
                
                    var fetchedMessage = fetchResultsOnConfirmation[0]
                    
    //                for dm in fetchResultsOnConfirmation {
    //                    if (dm.id == NSDecimalNumber(string: confirmationId)) {
    //                        fetchedMessage = dm
    //                    }
    //                }
                    
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "DM",
                        in: context
                    )!
                    
                    let DMModel = DM(
                        entity: entityDescription,
                        insertInto: context
                    )
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let date = dateFormatter.date(from: "\(data["date"]!)")
                    
                    let currentAccount = self.client.getCurrentAccount()

                    
                    DMModel.username = currentAccount.username
                    DMModel.message = message
                    DMModel.date = date
                    DMModel.id = data["id"]!
                    DMModel.senderId = currentAccount.userId
                    DMModel.receiverId = receiver.id
                    
                    print("=========================")
                    print(DMModel)
                    print("=========================")
                    
                    context.delete(fetchedMessage)
                    try! context.save()
                    
                    self.sortChats(chatId: receiver.id!)
                    self.socket.off("dm_confirmation")
                }
            }
        }
    }
        
       
    
    public func fetchDMs(chatId: String) {
        let context = self.client.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
//        fetchRequest.predicate = NSPredicate(format: "chatId == %@", NSNumber(value: chatId))
//        let chat = try! context.fetch(fetchRequest) as! [Chat]

//        let DMFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
//        let senderPredicate = NSPredicate(format: "senderId == %@", NSNumber(value: chatId))
//        let receiverPredicate = NSPredicate(format: "receiverId == %@", NSNumber(value: chatId))
//        DMFetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: [senderPredicate, receiverPredicate])
        
        
        self.socket.emit("fetch_dms", ["sender": chatId])
        
        self.socket.on("fetch_dms") { dataArray, socketAck in
            
            let data: [[String: Any]] = dataArray[0] as! [[String: Any]]
            
            for dm in data {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
                fetchRequest.predicate = NSPredicate(format: "id == %@", dm["id"] as! CVarArg)
                let allDMsWithSameId = try! context.fetch(fetchRequest) as! [DM]
                
                if(allDMsWithSameId == []) {
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "DM",
                        in: context
                    )!
                    
                    let DMModel = DM(
                        entity: entityDescription,
                        insertInto: context
                    )
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let date = dateFormatter.date(from: "\(dm["date"]!)")
                    
                    
                    let receiverId: Int = Int("\(dm["receiver"] ?? "")")!
                    let senderId: Int = Int("\(dm["sender"] ?? "")")!
                    
                    DMModel.username = dm["username"] as? String
                    DMModel.message = dm["message"] as? String
                    DMModel.date = date
                    DMModel.id = dm["id"] as! String
                    DMModel.senderId = "\(String(describing: senderId))" as! String
                    DMModel.receiverId = "\(String(describing: receiverId))" as! String
                    
//                    let fetchChatRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
//                    fetchChatRequest.predicate = NSPredicate(format: "chatId == %@", NSNumber(value: chatId))
//                    var chat = try! context.fetch(fetchChatRequest) as! [Chat]
//
//                    if(chat != []) {
//                        chat[0].lastMessage = DMModel.message
//                        chat[0].lastMessageAuthor = DMModel.username
//                        chat[0].lastMessageId = DMModel.id
//                        chat[0].date = DMModel.date
//                        chat[0].isRead = true
//                    }
//
//                    var chatId: Int64
//                    let currentAccount = self.client.getCurrentAccount()
//
//                    if(DMModel.receiverId == currentAccount.userId) { chatId = DMModel.senderId }
//                    else { chatId = DMModel.receiverId }
                    
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
                        
                        MediaModel.chatId = chatId as! String
                        MediaModel.type = mediaElement["type"] as! Int16
                        MediaModel.messageId = DMModel.id as! String
                        MediaModel.url = mediaElement["mediaURL"] as! String
                    }
                        
                    
                    try! context.save()
                }
                self.socket.emit("delete_dms", ["sender": chatId, "from": dm["id"], "to": dm["id"]])
            }
            self.sortChats(chatId: chatId)
        }
    }
    
    public func getDMMessage(completion: @escaping (DM) -> Void) {
        socket.on("send_dm") { dataArray, socketAck in
            print("dostałem wiadomość")
            let context = self.client.persistentContainer.viewContext

            let data = dataArray[0] as! [String: Any]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
            fetchRequest.predicate = NSPredicate(format: "id == %@", data["id"] as! CVarArg)
            let allDMsWithSameId = try! context.fetch(fetchRequest) as! [DM]
            
            let receiverId: String = "\(data["receiverId"] ?? "")"
            let senderId: String = "\(data["senderId"] ?? "")"
            
            var chatId: String
            let currentAccount = self.client.getCurrentAccount()
            
            if(receiverId == currentAccount.userId) { chatId = senderId }
            else { chatId = receiverId }
            
            print("+++++")
            print(allDMsWithSameId)
            print("+++++")
        
            if(allDMsWithSameId == []) {
                let fetchRequestForIsFirstMessage = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
                
//                let predicateForReceiver = NSPredicate(format: "receiverId == %@", NSString(string: senderId))
//                let predicateForSender = NSPredicate(format: "senderId == %@", NSString(string: receiverId))
//                let finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateForSender, predicateForReceiver])

                
                let predicateForReceivedMessageReceived = NSPredicate(format: "receiverId == %@", NSString(string: receiverId))
                let predicateForSendMessageReceived = NSPredicate(format: "receiverId == %@", NSString(string: senderId))
                let predicateForSendMessageSend = NSPredicate(format: "senderId == %@", NSString(string: receiverId))
                let predicateForReceivedMessageSend = NSPredicate(format: "senderId == %@", NSString(string: senderId))
                
                let predicateAndReceived = NSCompoundPredicate(type: .and, subpredicates: [predicateForReceivedMessageSend, predicateForReceivedMessageReceived])
                let predicateAndSend = NSCompoundPredicate(type: .and, subpredicates: [predicateForSendMessageSend, predicateForSendMessageReceived])
                
                let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateAndSend, predicateAndReceived])
                
                fetchRequestForIsFirstMessage.predicate = finalPredicate
                
                let isFirstMessage = try! context.fetch(fetchRequestForIsFirstMessage) as! [DM]
               
                var privateKeyPem: String = ""
                
                if (isFirstMessage == []) {
                    print("FIRST MESSAGE")
                    privateKeyPem = self.client.keychain["\(currentAccount.id)-e2ePublicKey"]!
                    let newE2EPrivateKey = generatePrivateKey()
                    let e2ePublicKeyPem = newE2EPrivateKey.publicKey.pemRepresentation
                    self.socket.emit("update_public_e2e_key", ["key": e2ePublicKeyPem])
                    self.socket.on("update_public_e2e_key") {_,_ in
                        self.client.keychain["\(currentAccount.id)-e2ePublicKey"] = newE2EPrivateKey.pemRepresentation
                        self.socket.off("update_public_e2e_key")
                    }
                    self.client.keychain["\(chatId)-e2ePrivateKey"] = privateKeyPem
                } else {
                    print("NOT FIRST MESSAGE")
                    privateKeyPem = self.client.keychain["\(senderId)-e2ePrivateKey"]!
                }
                
                let privateKey = try! P256.KeyAgreement.PrivateKey(pemRepresentation: privateKeyPem)
                
                let senderDeviceId: String = data["deviceId"] as! String
               
                let context = self.client.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "E2EKey")
                fetchRequest.predicate = NSPredicate(format: "deviceId == %@", NSString(string: senderDeviceId))
                let fetchResults = try! context.fetch(fetchRequest) as! [E2EKey]
                
                var publicKeyPem = data["senderNewPublicKey"] as! String
                
//                if(fetchResults == []) {
//                    publicKeyPem = data["senderNewPublicKey"] as! String
//                } else {
//                    publicKeyPem = fetchResults[0].key as! String
//                }
                
                let publicKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: publicKeyPem)
                let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: publicKey)
            
                var encryptedMessage: [String: String] = [:]
                
                for message in data["message"] as! [[String: String]] {
                    if (message["deviceId"] == currentAccount.deviceId) {
                        encryptedMessage = message
                    }
                }
                
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
                
                let entityDescription = NSEntityDescription.entity(
                    forEntityName: "DM",
                    in: context
                )!
                
                let DMModel = DM(
                    entity: entityDescription,
                    insertInto: context
                )
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from: "\(data["date"]!)")

                DMModel.username = data["username"] as? String
                DMModel.message = decryptedMessage as? String
                DMModel.date = date
                DMModel.id = data["id"] as? String
                DMModel.senderId = "\(String(describing: senderId))"
                DMModel.receiverId = "\(String(describing: receiverId))" as! String
                
                let media = data["media"] as! [[String: Any]]
                
                for mediaElement in media {
                    let entityDescription = NSEntityDescription.entity(
                        forEntityName: "Media",
                        in: context
                    )!

                    let MediaModel = Media(
                        entity: entityDescription,
                        insertInto: context
                    )
                    
                    MediaModel.chatId = chatId as! String
                    MediaModel.type = mediaElement["type"] as! Int16
                    MediaModel.messageId = DMModel.id as! String
                    MediaModel.url = mediaElement["mediaURL"] as! String
                }
               
               
                // TUTAJ ZRÓB TO SAMO CO POWYŻEJ LINIA 326 <-------
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
                    
                    model.key = data["senderNewPublicKey"] as! String
                    model.userId = chatId as! String
                    model.deviceId = senderDeviceId as! String
                    
                    try! context.save()
                } else {
                    fetchResultsForE2EKey[0].key = data["senderNewPublicKey"] as! String
                    
                    try! context.save()
                }
                
                self.sortChats(chatId: chatId)

                try! context.save()
            }
            self.socket.emit("delete_dms", ["sender": chatId, "from": data["id"], "to": data["id"]])
        }
    }
    
    public func stopReceivingMessages() {
        socket.off("send_dm")
    }
    
    private func sortChats(chatId: String) {
        let context = self.client.persistentContainer.viewContext
        let currentAccount = self.client.getCurrentAccount()
        var chats = self.getChats()
        
        if(self.isChatInDB(chatId: chatId)) {
            for chat in chats {
                if(chat.chatId == chatId) {
                    chat.id = 0
                    break
                } else {
                    chat.id += 1
                }
            }

            chats = chats.sorted { $0.id > $1.id }
            try! context.save()
        } else {
            let entityDescription = NSEntityDescription.entity(
                forEntityName: "Chat",
                in: context
            )!

            let newChatModel = Chat(
                entity: entityDescription,
                insertInto: context
            )
            
            for chat in chats {
                chat.id += 1
            }

            newChatModel.userId = currentAccount.id
            newChatModel.chatId = chatId as! String
            newChatModel.id = 0 as Int64
            
            self.socket.emit("get_information_about_account", chatId)

            self.socket.on("get_information_about_account") { dataArray, socketAck in
                let data = dataArray[0] as! [String: Any]
                print(data)
                newChatModel.name = data["username"] as? String
                //model.avatar = data["avatar"] as? String
                //print(model.avatar)
                chats = chats.sorted { $0.id > $1.id }
                try! context.save()
                self.socket.off("get_information_about_account")
            }
        }
    }
     
    
//    public func getLastUnreadChats() -> [Chat] {
//        let context = self.client.persistentContainer.viewContext
//        socket.emit("fetch_last_unread_dms")
//        socket.on("fetch_last_unread_dms") { dataArray, socketAck in
//            let entityDescription = NSEntityDescription.entity(
//                forEntityName: "Chat",
//                in: context
//            )!
//
//            let data = dataArray[0] as? [String: Any]
//            print("======")
//            print(data)
//            print("======")
//            if(data != nil) {
//                let model = Chat(
//                    entity: entityDescription,
//                    insertInto: context
//                )
//
//                let receiver = data!["receiver"]!
//                let sender = data!["sender"]
//                let isRead = data!["isRead"]
//
//                model.name = data!["username"] as? String
//                model.lastMessage = data!["message"] as? String
//                model.date = data!["date"] as? Date
//                model.userId = Int64(self.getDMId(receiver: receiver as! Int, sender: sender as! Int) + 1)
//                model.chatId = Int64("\(String(describing: sender!))")!
//                model.type = "DM"
//                model.isRead = isRead as! Bool
//
//                try! context.save()
//            }
//        }
//    }
        
    public func getChats() -> [Chat] {
        let context = self.client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let chats = try! context.fetch(fetchRequest) as! [Chat]

        let currentAccount = self.client.getCurrentAccount()

        var chatsForUser: [Chat] = []
        for chat in chats {
            if(chat.userId == currentAccount.id) {
                chatsForUser.append(chat)
            }
        }

        return chatsForUser.sorted { $0.id < $1.id }
    }
        
    func getDMId() -> Int {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
        let messages = try! context.fetch(fetchRequest) as! [DM]

        var messageId: Int = 0
        if(messages != []) {
            for _ in messages {
                messageId+=1
            }
        }
        return messageId
    }
        
    func isChatInDB(chatId: String) -> Bool {
        let chats = getChats()

        for chat in chats {
            if(chat.chatId == chatId) {
                return true
            }
        }

        return false
    }
    
    public func getDMsFromDB(user: User) -> [DM] {
        let context = client.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
        let messages = try! context.fetch(fetchRequest) as! [DM]

        let currentAccount = client.getCurrentAccount()

        var messagesForRoom: [DM] = []
        if(messages != []) {
            for message in messages {
                if(message.receiverId == user.id && message.senderId == currentAccount.userId || message.receiverId == currentAccount.userId && message.senderId == user.id) {
                    messagesForRoom.append(message)
                }
            }
        }

        return messagesForRoom
    }
}

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    public func chatToUser(chat: Chat) -> User {
        let context = self.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "User",
            in: context
        )!
        
        let model = User(
            entity: entityDescription,
            insertInto: context
        )
        
        model.avatar = chat.avatar
        model.username = chat.name
        model.id = chat.chatId
        
        return model
    }
}
    
    

//
//    public func getLastDMs() -> [LastDM] {
//        let context = self.client.persistentContainer.viewContext
//        socket.emit("fetch_last_unread_dms")
//        socket.on("fetch_last_unread_dms") { dataArray, socketAck in
//            let entityDescription = NSEntityDescription.entity(
//                forEntityName: "LastDM",
//                in: context
//            )!
//
//            let model = LastDM(
//                entity: entityDescription,
//                insertInto: context
//            )
//
//            let data = dataArray[0] as! [String: Any]
//            let receiverId = data["receiver"]
//            let senderId = data["sender"]
//
//            model.username = data["username"] as? String
//            model.lastMessage = data["message"] as? String
//            model.date = data["date"] as? Date
//            model.userId = Int64(self.getLastDMId(receiverId: receiverId as! Int, senderId: senderId as! Int) + 1)
//            model.receiverId = Int64("\(String(describing: senderId!))")!
//
//            try! context.save()
//        }
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastDM")
//        let dms = try! context.fetch(fetchRequest) as! [LastDM]
//
//        let currentAccount = self.client.getCurrentAccount()
//
//        var lastDMsForUser: [LastDM] = []
//        for dm in dms {
//            if(dm.userId == currentAccount.id) {
//                lastDMsForUser.append(dm)
//            }
//        }
//
//        return lastDMsForUser.sorted { $0.id < $1.id }
//    }
//
//    private func getLastDMId(receiverId: Int, senderId: Int) -> Int {
//        let context = client.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DM")
//        let messages = try! context.fetch(fetchRequest) as! [DM]
//
//        var messageId: Int = 0
//        if(messages != []) {
//            for message in messages {
//                if(message.receiverId == receiverId && message.senderId == senderId || message.receiverId == senderId && message.senderId == receiverId) {
//                    messageId+=1
//                }
//            }
//        }
//        return messageId
//    }
//
//    private func setLastDM(receivedDM: DM) {
//        let context = client.persistentContainer.viewContext
//        let currentAccount = client.getCurrentAccount()
//        var dms = getLastDMs()
//
//        var userId: Int64
//
//        if(receivedDM.receiverId == currentAccount.userId) { userId = receivedDM.senderId }
//        else { userId = receivedDM.receiverId }
//
//        if(isReceiverIdInDB(receiverId: userId)) {
//            for dm in dms {
//                if(dm.receiverId == userId) {
//                    dm.id = 0
//                } else {
//                    dm.id += 1
//                }
//            }
//
//            dms = dms.sorted { $0.id > $1.id }
//            try! context.save()
//        } else {
//            let entityDescription = NSEntityDescription.entity(
//                forEntityName: "LastDM",
//                in: context
//            )!
//
//            let model = LastDM(
//                entity: entityDescription,
//                insertInto: context
//            )
//
//            for dm in dms {
//                dm.id += 1
//            }
//
//            model.userId = currentAccount.id
//            model.receiverId = userId
//            model.id = 0 as Int64
//
//            socket.emit("get_information_about_account", Int(userId))
//
//            socket.on("get_information_about_account") { dataArray, socketAck in
//                let data = dataArray[0] as! [String: Any]
//                model.username = data["username"] as? String
//                //model.avatar = data["avatar"] as? String
//                //print(model.avatar)
//                dms = dms.sorted { $0.id > $1.id }
//                try! context.save()
//            }
            
//            let url = URL(string: "\(client.API_ROUTE)v\(client.API_VERSION)/getInformationAboutAccount")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            let payload: [String: Any] = [
//                "userId": userId
//            ]
//            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
//
//            let timestamp = NSDate().timeIntervalSince1970
//            let authToken = client.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "getInformationAboutAccount")
//
//            request.addValue(authToken ?? "", forHTTPHeaderField: "AuthToken")
//
//            DispatchQueue.main.async { [self] in
//                client.request(request: request, timestamp: timestamp) { value in
//                    switch value {
//                    case .success(let response):
//                        model.username = response["data"]["username"].stringValue
//                        model.avatar = response["data"]["avatar"].stringValue
//
//                        dms = dms.sorted { $0.id > $1.id }
//                        try! context.save()
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//            }
//        }
//    }
//
//    private func isReceiverIdInDB(receiverId: Int64) -> Bool {
//        let dms = getLastDMs()
//
//        for dm in dms {
//            if(dm.receiverId == receiverId) {
//                return true
//            }
//        }
//
//        return false
//    }
