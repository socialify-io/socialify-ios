//
//  SocialifyClient.swift
//
//
//  Created by Tomasz on 26/07/2021.
//

import Foundation
import UIKit

public class SocialifyClient {
    
    public init() {}
    
    // MARK: - Public variables
    
    public let LIBRARY_VERSION = "0.1"
    
    // MARK: - Class variables
    let API_VERSION = "0.1"
    let API_ROUTE = "http://127.0.0.1:5000/api/"
    
    let systemVersion = UIDevice.current.systemVersion
    let userAgent = "Socialify-iOS"
}
