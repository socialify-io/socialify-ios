//
//  errorModel.swift
//  
//
//  Created by Tomasz on 27/07/2021.
//

import Foundation

@available(iOS 13.0, *)
extension SocialifyClient {
    
    // MARK: - Errors models
    
    public enum ApiError: Error {
        case UnexpectedError
    }
}
