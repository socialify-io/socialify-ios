//
//  ErrorReportModel.swift
//
//
//  Created by Tomasz on 02/08/2021.
//

import Foundation

@available(iOS 14.0, *)
extension SocialifyClient {
    
    public struct ErrorReport {
        public init(errorType: Error?,
                    errorContext: String?,
                    messageTitle: String?,
                    message: String?
            ) {
            self.errorType = errorType
            self.errorContext = errorContext
            self.messageTitle = messageTitle
            self.message = message
        }
        
        var errorType: Error?
        var errorContext: String?
        var messageTitle: String?
        var message: String?
    }
}
