//
//  request.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation
import BCryptSwift
import SwiftyJSON
import SwiftRSA

@available(iOS 13.0, *)
extension SocialifyClient {
    
    // MARK: - Sending request
    
    func request(request: URLRequest, authTokenHeader: String, completion: @escaping (Result<JSON, ApiError>) -> Void) {
        var request = request
        let timestamp = NSDate().timeIntervalSince1970
        
        let salt = BCryptSwift.generateSalt()
        let authToken = BCryptSwift.hashPassword("$begin-\(authTokenHeader)$.\(LIBRARY_VERSION)+\(systemVersion)+\(userAgent)#\(timestamp)#.$end-\(authTokenHeader)$", withSalt: salt)
        
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
            
            do {
                let responseBody = try JSON(data: data)
                
                completion(.success(responseBody))
            } catch {
                print("nie dziala :(")
                print(String(data: data, encoding: String.Encoding.utf8))
            }
        }.resume()
    }
}
