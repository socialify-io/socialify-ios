//
//  register.swift
//  
//
//  Created by Tomasz on 28/07/2021.
//

import Foundation
import SwiftyRSA

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
                        let passwordClear = try ClearMessage(string: password, using: .utf8)
                        let repeatedPasswordClear = try ClearMessage(string: repeatedPassword, using: .utf8)
                        
                        let encryptedPassword = try passwordClear.encrypted(with: value.0, padding: .OAEP).data.base64EncodedString() // 0 means model of public key
                        let encryptedRepeatedPassword = try repeatedPasswordClear.encrypted(with: value.0, padding: .OAEP).data.base64EncodedString()
                        
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
}
