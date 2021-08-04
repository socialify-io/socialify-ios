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
        case BadRequest

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
        case RSAKeyGenerationError
        case RSAPublicKeyToStringError
        case RSAPrivateKeyToStringError
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
            case 7:     return ApiError.BadRequest
            
            // Request sign
            case 8:     return ApiError.InvalidAuthToken
            case 9:     return ApiError.InvalidHeaders
            case 10:     return ApiError.InvalidFingerprint
            case 11:    return ApiError.InvalidSignature
            case 12:    return ApiError.InvalidRequestPayload
        
            default:    return ApiError.UnexpectedError
        }
    }
}
