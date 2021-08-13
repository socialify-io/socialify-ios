//
//  SocialifyClient.swift
//
//
//  Created by Tomasz on 26/07/2021.
//

import Foundation
import UIKit
import os
import Combine
import CoreData
import KeychainAccess
import SocketIO

@available(iOS 14.0, *)
public final class SocialifyClient: ObservableObject {
    static public let shared: SocialifyClient = SocialifyClient()
    
    let manager = SocketManager(socketURL: URL(string: "ws://localhost:80")!, config: [.log(true), .compress, .forcePolling(true)])
    
    public init() {}
    
    // MARK: - Public variables
    
    public let LIBRARY_VERSION = "0.1"
    
    // MARK: - Class variables
    let API_VERSION = "0.1"
    let API_ROUTE = "http://127.0.0.1:5000/api/"
    
    let deviceModel = UIDevice.modelName
    let systemVersion = "iOS_\(UIDevice.current.systemVersion)"
    let userAgent = "Socialify-iOS"
    
    let persistentContainer: NSPersistentContainer = CoreDataModel.shared.persistentContainer
    let ud = UserDefaults.group
    let keychain = Keychain()
}
