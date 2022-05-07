//
//  SocialifyClient.swift
//
//
//  Created by Tomasz on 26/07/2021.
//

import Foundation
import UIKit
import Combine
import CoreData
import KeychainAccess
import SocketIO

@available(iOS 14.0, *)
public final class SocialifyClient: ObservableObject {
    static public let shared: SocialifyClient = SocialifyClient()
    
    public init() {}
    
    // MARK: - Public variables
    
    public let LIBRARY_VERSION = "0.1"
    
    // MARK: - Class variables
    public let API_VERSION = "0.1"
    public let API_ROUTE = "http://api.socialify.me/api/"
    
    public let deviceModel = UIDevice.modelName
    public let systemVersion = "iOS_\(UIDevice.current.systemVersion)"
    public let userAgent = "Socialify-iOS"
    
    public let persistentContainer: NSPersistentContainer = CoreDataModel.shared.persistentContainer
    let ud = UserDefaults.group
    public let keychain = Keychain()
}
