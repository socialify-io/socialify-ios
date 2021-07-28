//
//  request.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation
import BCryptSwift

extension SocialifyClient {
    
    // MARK: - Sending request
    
    func request(request: URLRequest, completion: @escaping (Result<Bool, ApiError>) -> Void) {
        var request = request
        let timestamp = NSDate().timeIntervalSince1970
        
        let salt = BCryptSwift.generateSalt()
        let authToken = BCryptSwift.hashPassword("$begin-getKey$.\(LIBRARY_VERSION)+\(systemVersion)+\(userAgent)#\(timestamp)#.$end-getKey$", withSalt: salt)
        print("Hashed result is: \(authToken)")
        
        request.allHTTPHeaderFields = [
            "Content-Type": "applictaion/json",
            "User-Agent": userAgent,
            "OS": systemVersion,
            "Timestamp": "\(timestamp)",
            "AppVersion": LIBRARY_VERSION,
            "AuthToken": "\(authToken ?? "")"
        ]
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            guard let data = data else {
                  if let _ = error {
                    completion(.failure(ApiError.UnexpectedError))
                  }

                completion(.failure(ApiError.UnexpectedError))
                return
                }
            
            print(String(data: data as! Data, encoding: String.Encoding.utf8))
            
            completion(.success(true))
        }.resume()
    }
}
