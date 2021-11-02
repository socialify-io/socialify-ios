//
//  friends.swift
//
//
//  Created by Tomasz on 25/09/2021.
//

import Foundation
import CryptoKit

@available(iOSApplicationExtension 14.0, *)
extension SocialifyClient {
    
    public func sendFriendRequest(id: Int64) {
        var client: SocialifyClient = SocialifyClient.shared
        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/sendFriendRequest")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let payload = [
            "userId": id
        ]
        
        let account = client.getCurrentAccount()
        var privKeyPEM = client.keychain["\(account.id)-privateKey"]
          
        let timestamp = NSDate().timeIntervalSince1970
        let authToken = client.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "sendFriendRequest")

        let fingerprint = Insecure.SHA1.hash(data: privKeyPEM!.data(using: .utf8)!).hexStr
        
        var headersJson: [String: String] = [
            "AuthToken": "\(authToken ?? "")",
            "Fingerprint": fingerprint,
            "DeviceId": "\(account.deviceId)"
        ]
        
        let headers = "Content-Type=application/json&User-Agent=\(client.userAgent)&OS=\(client.systemVersion)&Timestamp=\(Int(timestamp))&AppVersion=\(client.LIBRARY_VERSION)&AuthToken=\(authToken ?? "")&Fingerprint=\(fingerprint)&DeviceId=\(account.deviceId)&"
        
        let signatureCore = "headers=\(headers)&body={\"userId\": \(id)}&timestamp=\(Int(timestamp))&authToken=\(authToken ?? "")&endpointUrl=/api/v0.1/sendFriendRequest&"
        
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
        
        let base64Signature = signature.base64EncodedString
        print(signatureCore)
            
        headersJson.updateValue("\(base64Signature)", forKey: "Signature")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        request.allHTTPHeaderFields = headersJson
        
        
        
        self.request(request: request, timestamp: timestamp) { value in
            switch value {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}
