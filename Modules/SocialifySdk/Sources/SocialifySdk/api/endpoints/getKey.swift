//
//  getKey.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation
import SwiftyJSON
import SwiftyRSA

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Getting public RSA key to encrypt password
    
    func getKey(completion: @escaping (Result<(PublicKey, String), Error>) -> Void) {
        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/getKey")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let timestamp = NSDate().timeIntervalSince1970
        let authToken = self.generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: "getKey")
        
        request.addValue(authToken ?? "", forHTTPHeaderField: "AuthToken")
        
        self.request(request: request, timestamp: timestamp) { value in
            switch value {
            case .success(let value):
                let pubKeyPem = "\(value["data"]["pubKey"])"
                let publicKey = try! PublicKey(pemEncoded: pubKeyPem)
                completion(.success((publicKey, pubKeyPem)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
