//
//  getKey.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation
import SwiftyJSON
import SwiftyRSA
import CryptoKit

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Getting public RSA key to encrypt password
    
    func getKey(completion: @escaping (Result<(P256.KeyAgreement.PublicKey, String), Error>) -> Void) {
        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/getKey")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let timestamp = NSDate().timeIntervalSince1970
        let authToken = self.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "getKey")
        
        request.addValue(authToken ?? "", forHTTPHeaderField: "AuthToken")
        
        self.request(request: request, timestamp: timestamp) { value in
            switch value {
            case .success(let value):
//                var keyDict = [NSObject: NSObject]()
//                keyDict[kSecAttrKeyType] = kSecAttrKeyTypeEC
//                keyDict[kSecAttrKeyClass] = kSecAttrKeyClassPublic
//                keyDict[kSecAttrKeySizeInBits] = NSNumber(value: 256)
//                keyDict[kSecReturnPersistentRef] = true as NSObject
               
                
                
                let pubKeyPem = "\(value["data"]["pubKey"])"
                let pubKeyData = pubKeyPem.data(using: String.Encoding.ascii)
                var error: Unmanaged<CFError>?
                //let publicKey = SecKeyCreateWithData(pubKeyData! as CFData, keyDict as CFDictionary, &error)
                //let publicKey: SecKey = pubKeyPem as! SecKey
                let publicKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: pubKeyPem)
                completion(.success((publicKey, pubKeyPem)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
