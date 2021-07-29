//
//  register.swift
//  
//
//  Created by Tomasz on 28/07/2021.
//

import Foundation
import SwiftRSA

@available(iOS 13.0, *)
extension SocialifyClient {
    
    // MARK: - Creating new Socialify account
    
    public func register(username: String, password: String, repeatedPassword: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.getKey() { value in
            switch value {
            case .success(let value):
                do {
                    let passwordClearText = ClearText(string: password)
                    let repeatedPasswordClearText = ClearText(string: repeatedPassword)
                    
                    let encryptedPassword = try passwordClearText.encrypted(with: value.0, by: .rsaEncryptionOAEPSHA1).data.base64EncodedString() // 0 means model of public key
                    let encryptedRepeatedPassword = try repeatedPasswordClearText.encrypted(with: value.0, by: .rsaEncryptionOAEPSHA1).data.base64EncodedString()
                    
                    let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/register")!
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    
                    let payload = [
                        "username": username,
                        "password": encryptedPassword,
                        "repeat_password": encryptedRepeatedPassword,
                        "pubKey": value.1 // 1 means public key as string
                    ]
                    
                    let jsonPayload = try? JSONSerialization.data(withJSONObject: payload)
                    
                    request.httpBody = jsonPayload
                    
                    self.request(request: request, authTokenHeader: "register") { value in
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
