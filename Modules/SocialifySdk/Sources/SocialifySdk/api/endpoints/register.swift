//
//  register.swift
//  
//
//  Created by Tomasz on 28/07/2021.
//

import Foundation

@available(iOS 13.0, *)
extension SocialifyClient {
    
    // MARK: - Creating new Socialify account
    
    public func register(username: String, password: String, repeatedPassword: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.getKey() { value in
            switch value {
            case .success(_):
                print("GetKey works!")
                
            case .failure(let error):
                print(error)
            }
        }
        completion(.success(true))
    }
}
