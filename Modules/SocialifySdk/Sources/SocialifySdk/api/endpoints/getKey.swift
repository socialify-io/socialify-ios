//
//  getKey.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation

@available(iOS 13.0, *)
extension SocialifyClient {
    
    // MARK: - Getting public RSA key to encrypt password
    
    func getKey(completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/getKey")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.request(request: request) { value in
            switch value {
            case .success(_):
                print("request works!")
                
            case .failure(let error):
                print(error)
            }
        }
        
        completion(.success(true))
    }
}
