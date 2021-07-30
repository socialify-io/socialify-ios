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
        
        // Register
        case InvalidUsername
        case InvalidRepeatPassword

        // Login
        case InvalidPassword

        // Crypto
        case InvalidPublicRSAKey
        case InvalidPasswordEncryption

        // Server
        case InternalServerError

        // Request sign
        case InvalidAuthToken
        case InvalidHeaders
        case InvalidFingerprint
        case InvalidSignature
        case InvalidRequestPayload
    }
    
    public enum SdkError: Error {
        case UnexpectedError
        
        // Request parsing
        case ResponseParseError
        case NoInternetConnection
        
        // Crypto
        case RSAError
    }
    
    // MARK: - Errors functions
    
    func parseErrorCode(errorCode: Int) -> ApiError {
        switch errorCode {
            case 0:     return ApiError.UnexpectedError
            
            // Register
            case 1:     return ApiError.InvalidUsername
            case 2:     return ApiError.InvalidRepeatPassword
            
            // Login
            case 3:     return ApiError.InvalidPassword
            
            // Crypto
            case 4:     return ApiError.InvalidPublicRSAKey
            case 5:     return ApiError.InvalidPasswordEncryption
            
            // Server
            case 6:     return ApiError.InternalServerError
            
            // Request sign
            case 7:     return ApiError.InvalidAuthToken
            case 8:     return ApiError.InvalidHeaders
            case 9:     return ApiError.InvalidFingerprint
            case 10:    return ApiError.InvalidSignature
            case 11:    return ApiError.InvalidRequestPayload
        
            default:    return ApiError.UnexpectedError
        }
    }
}
