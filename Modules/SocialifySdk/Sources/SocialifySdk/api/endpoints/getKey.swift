//
//  getKey.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation
import SwiftyJSON
import SwiftRSA

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Getting public RSA key to encrypt password
    
    func getKey(completion: @escaping (Result<(PublicKey, String), Error>) -> Void) {
        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/getKey")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        self.request(request: request, authTokenHeader: "getKey") { value in
            switch value {
            case .success(let value):
                let pubKeyPem = "\(value["data"]["pubKey"])"
                let publicKey = PublicKey(pemEncoded: pubKeyPem)
                completion(.success((publicKey!, pubKeyPem)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
