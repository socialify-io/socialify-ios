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

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Sending request
    
    func request(request: URLRequest, authTokenHeader: String, completion: @escaping (Result<JSON, Error>) -> Void) {
        var request = request
        let timestamp = NSDate().timeIntervalSince1970
        
        let authToken = generateAuthToken(timestamp: "\(Int(timestamp))", authTokenHeader: authTokenHeader)
        
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "User-Agent": userAgent,
            "OS": systemVersion,
            "Timestamp": "\(Int(timestamp))",
            "AppVersion": LIBRARY_VERSION,
            "AuthToken": "\(authToken ?? "")"
        ]
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if(error?._code.littleEndian == -1004) {
                completion(.failure(SdkError.NoInternetConnection))
            } else {
                guard let data = data else {
                      if let _ = error {
                        completion(.failure(ApiError.UnexpectedError))
                      }
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
            }
        }.resume()
    }
    
    func generateAuthToken(timestamp: String, authTokenHeader: String) -> String? {
        let salt = BCryptSwift.generateSalt()
        return BCryptSwift.hashPassword("$begin-\(authTokenHeader)$.\(LIBRARY_VERSION)+\(systemVersion)+\(userAgent)#\(timestamp)#.$end-\(authTokenHeader)$", withSalt: salt)
    }
}
