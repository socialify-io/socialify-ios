//
//  SocketIOManager.swift
//  SocketIOManager
//
//  Created by Tomasz on 17/08/2021.
//

import Foundation
import SocketIO
import UIKit
import Combine
import KeychainAccess
import CoreData
import CryptoKit

@available(iOS 14.0, *)
public class SocketIOManager: NSObject {
    var client: SocialifyClient = SocialifyClient.shared
    static public let sharedInstance = SocketIOManager()
    
    func getWebsocketHeaders() -> [String: String] {
        let account = client.getCurrentAccount()
        var privKeyPEM = client.keychain["\(account.id)-privateKey"]
          
        let timestamp = NSDate().timeIntervalSince1970
        let authToken = client.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "connect")
            
        let fingerprint = Insecure.SHA1.hash(data: privKeyPEM!.data(using: .utf8)!).hexStr
        
        var headersJson: [String: String] = [
            "Content-Type": "application/json",
            "User-Agent": client.userAgent,
            "OS": client.systemVersion,
            "Timestamp": "\(Int(timestamp))",
            "AppVersion": client.LIBRARY_VERSION,
            "AuthToken": "\(authToken ?? "")",
            "Fingerprint": fingerprint,
            "DeviceId": "\(account.deviceId)"
        ]
        
        let headers = "Content-Type=application/json&User-Agent=\(client.userAgent)&OS=\(client.systemVersion)&Timestamp=\(Int(timestamp))&AppVersion=\(client.LIBRARY_VERSION)&AuthToken=\(authToken ?? "")&Fingerprint=\(fingerprint)&DeviceId=\(account.deviceId)&"
        
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
    
    private override init() {
        super.init()
    }
    
    public func connect() {
        socket.connect()
    }
    
    lazy var manager = SocketManager(socketURL: URL(string: "http://localhost:80")!, config: [.log(true), .compress, .extraHeaders(getWebsocketHeaders())])
    lazy var socket = manager.defaultSocket
}
