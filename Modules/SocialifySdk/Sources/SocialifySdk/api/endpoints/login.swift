//
//  login.swift
//
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation
import SwiftRSA
import SwiftUI
import CryptoKit

@available(iOS 13.0, *)
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
                        case .success(let value):
                            print(value)
                            completion(.success(true))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }

                } catch {
                    completion(.failure(SdkError.RSAError))
                }
                
                completion(.success(true))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
