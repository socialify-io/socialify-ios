//
//  chats.swift
//
//
//  Created by Tomasz on 09/08/2021.
//

import Foundation
import SocketIO
import CryptoKit
import SwiftyRSA
import CoreData
import CommonCrypto
import BCryptSwift

@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func join(roomId: String) {
        manager.config = [.log(true), .compress, .forcePolling(true)]
        let socket = manager.defaultSocket
        
        socket.connect()

        socket.emit("join", ["room": roomId])
                    
        let context = self.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "Room",
            in: context
        )!
                
        let model = Room(
            entity: entityDescription,
            insertInto: context
        )
        
        model.roomId = roomId

        let rooms = self.fetchRooms()
    
        var id: Int64 = 0 as Int64
        
        if(rooms != []) {
            id = rooms[rooms.count-1].value(forKey: "id") as! Int64 + 1
        }
        
        model.id = id
    
        try! context.save()
    }
    
    public func send(message: String, room: Room) {
        let headers = getWebsocketHeaders()
        manager.config = [.log(true), .compress, .extraHeaders(headers)]
        let socket = manager.defaultSocket
        
        socket.connect()
        socket.emit("message", ["room": room.roomId, "message": message])
    }
    
    private func getWebsocketHeaders() -> [String: String] {
        let account = getCurrentAccount()
        var privKeyPEM = keychain["\(account.id)-privateKey"]
          
        let timestamp = NSDate().timeIntervalSince1970
        let authToken = generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "connect")
            
        let fingerprint = Insecure.SHA1.hash(data: privKeyPEM!.data(using: .utf8)!).hexStr
        
        var headersJson: [String: String] = [
            "Content-Type": "application/json",
            "User-Agent": userAgent,
            "OS": systemVersion,
            "Timestamp": "\(Int(timestamp))",
            "AppVersion": LIBRARY_VERSION,
            "AuthToken": "\(authToken ?? "")",
            "Fingerprint": fingerprint,
            "DeviceId": "\(account.deviceId)"
        ]
        
        let headers = "Content-Type=application/json&User-Agent=\(userAgent)&OS=\(systemVersion)&Timestamp=\(Int(timestamp))&AppVersion=\(LIBRARY_VERSION)&AuthToken=\(authToken ?? "")&Fingerprint=\(fingerprint)&DeviceId=\(account.deviceId)&"
        
        let signatureCore = "headers=\(headers)&body={}&timestamp=\(Int(timestamp))&authToken=\(authToken ?? "")&endpointUrl=/api/v0.1/connect&"
        
        privKeyPEM = privKeyPEM!
            .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        let keyData = Data(base64Encoded: privKeyPEM!, options: [.ignoreUnknownCharacters])
        
        let attributesRSAPriv: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048,
            kSecAttrIsPermanent as String: false
        ]
        
        var error: Unmanaged<CFError>?
        
        let secKey = SecKeyCreateWithData(keyData! as CFData, attributesRSAPriv as CFDictionary, &error)
        
        let algorithm: SecKeyAlgorithm = .rsaSignatureDigestPKCS1v15SHA1
        
        let data = try! Data(signatureCore.utf8)
        let digest = Insecure.SHA1.hash(data: data)
        let signature = SecKeyCreateSignature(secKey!, algorithm, digest.data as CFData, &error)! as NSData as Data
        
        let base64Signature = signature.base64EncodedString()
            
        headersJson.updateValue(base64Signature, forKey: "Signature")
        
        return headersJson
    }
}
