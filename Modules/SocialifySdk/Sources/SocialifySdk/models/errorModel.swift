//
//  errorModel.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation

extension SocialifyClient {
    
    // MARK: - Errors models
    
    public enum APIError: Error, LocalizedError {
        case unknown
        case error(reason: String)
        
        public var errorDescription: String? {
            switch self {
                case .unknown:
                    return "Unknown error"
                case .error (let reason):
                    return reason
            }
        }
    }
}
