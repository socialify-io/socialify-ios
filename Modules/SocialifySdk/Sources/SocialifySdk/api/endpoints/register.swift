//
//  register.swift
//  
//
//  Created by Tomasz on 28/07/2021.
//

import Foundation
import SwiftyRSA
import CryptoKit

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Creating new Socialify account
    
    public func register(username: String, password: String, repeatedPassword: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        if(password != repeatedPassword) {
            completion(.failure(ApiError.InvalidRepeatPassword))
        } else {
            self.getKey() { value in
                switch value {
                case .success(let value):
                    do {
                        let serverPublicKey = value.0
                        let privateKey = generatePrivateKey()
                        let symmetricKey = try! deriveSymmetricKey(privateKey: privateKey, publicKey: serverPublicKey)
                       
                        let encrypted = try! encrypt(text: password, symmetricKey: symmetricKey)
                        
                        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/register")!
                        
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        
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
                            
                        let payload = [
                            "username": username,
                            "password": encryptedPassword.base64EncodedString().dropFirst(16),
                            "pubKey": value.1,
                            "clientPubKey": privateKey.publicKey.pemRepresentation,
                            "nonce": nonce
                        ] as [String : Any]
                        
                        let jsonPayload = try? JSONSerialization.data(withJSONObject: payload)
                        
                        request.httpBody = jsonPayload
                        
                        let timestamp = NSDate().timeIntervalSince1970
                        let authToken = self.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "register")
                        
                        request.addValue(authToken ?? "", forHTTPHeaderField: "AuthToken")
                        
                        self.request(request: request, timestamp: timestamp) { value in
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
}
