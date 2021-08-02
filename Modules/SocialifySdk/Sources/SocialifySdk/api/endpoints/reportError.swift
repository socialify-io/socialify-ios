//
//  reportError.swift
//
//
//  Created by Tomasz on 02/08/2021.
//

import Foundation

extension SocialifyClient {
    
    public func reportError(report: ErrorReport, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(self.API_ROUTE)v\(self.API_VERSION)/reportError")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let payload: [String: Any] = [
            "errorType": report.errorType ?? "",
            "errorContext": report.errorContext ?? "",
            "messageTitle": report.messageTitle ?? "",
            "message": report.message ?? ""
        ]
        
        let jsonPayload = try? JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonPayload
        
        self.request(request: request, authTokenHeader: "reportError") { value in
            switch value {
            case .success(let value):
                print(value)
                completion(.success(true))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
