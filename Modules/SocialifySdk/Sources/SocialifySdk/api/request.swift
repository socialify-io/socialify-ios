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
    
    func request(request: URLRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        var request = request
        let timestamp = NSDate().timeIntervalSince1970
        
        let salt = BCryptSwift.generateSalt()
        let authToken = BCryptSwift.hashPassword("$begin-register$.\(LIBRARY_VERSION)+\(systemVersion)+\(userAgent)#\(timestamp)#.$end-register$", withSalt: salt)
        print("Hashed result is: \(authToken)")
        
        request.allHTTPHeaderFields = [
            "Content-Type": "applictaion/json",
            "User-Agent": userAgent,
            "OS": systemVersion,
            "Timestamp": "\(timestamp)",
            "AppVersion": LIBRARY_VERSION,
            "AuthToken": "\(authToken)"
        ]
        
//        session?.dataTask(with: request) { (data, response, error) in
//
//            guard let data = data else {
//                  if let _ = error {
//                    throw APIError.error(reason: "Error with connection.")
//                  }
//
//                throw APIError.error(reason: "Error with connection.")
//                return
//                }
//
//            return true
//        }.resume()
        
    completion(.success(true))
    }
}
