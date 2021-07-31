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
    
    func request(request: URLRequest, authTokenHeader: String, completion: @escaping (Result<JSON, Error>) -> Void) {
        var request = request
        let timestamp = NSDate().timeIntervalSince1970
        
        let authToken = generateAuthToken(timestamp: "\(timestamp)", authTokenHeader: authTokenHeader)
        
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

                completion(.failure(SdkError.NoInternetConnection))
                return
                }
            
            do {
                let responseBody = try JSON(data: data)
                if(responseBody["success"] == false) {
                    let errorCode: Int = responseBody["errors"][0]["code"].rawValue as! Int
                    completion(.failure(self.parseErrorCode(errorCode: errorCode)))
                } else if(responseBody["success"] == true) {
                    completion(.success(responseBody))
                } else {
                    completion(.failure(SdkError.UnexpectedError))
                }
                
            } catch {
                completion(.failure(SdkError.ResponseParseError))
            }
        }.resume()
    }
    
    func generateAuthToken(timestamp: String, authTokenHeader: String) -> String? {
        let salt = BCryptSwift.generateSalt()
        return BCryptSwift.hashPassword("$egin-\(authTokenHeader)$.\(LIBRARY_VERSION)+\(systemVersion)+\(userAgent)#\(timestamp)#.$end-\(authTokenHeader)$", withSalt: salt)
    }
}
