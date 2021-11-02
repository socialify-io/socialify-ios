//
//  request.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation
import BCryptSwift
import SwiftyJSON
import SwiftyRSA

@available(iOS 14.0, *)
extension SocialifyClient {
    
    // MARK: - Sending request
    
    func request(request: URLRequest, timestamp: TimeInterval, completion: @escaping (Result<JSON, Error>) -> Void) {
        var request = request
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(systemVersion, forHTTPHeaderField: "OS")
        request.addValue("\(Int(timestamp))", forHTTPHeaderField: "Timestamp")
        request.addValue(LIBRARY_VERSION, forHTTPHeaderField: "AppVersion")
        
        print(request.allHTTPHeaderFields)
        
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
                    print(responseBody)
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
