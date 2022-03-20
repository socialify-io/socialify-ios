//
//  File.swift
//  
//
//  Created by Tomasz on 16/03/2022.
//

import Foundation

@available(iOS 14.0, *)
extension SocialifyClient {
    
    public struct InfoAboutRoom {
        public init(roomId: Int,
                    isPublic: Bool,
                    roomName: String,
                    roomMembers: [String: String]
        ) {
            self.roomId = roomId
            self.isPublic = isPublic
            self.roomName = roomName
            self.roomMembers = roomMembers
        }
        
        public var roomId: Int
        public var isPublic: Bool
        public var roomName: String
        public var roomMembers: [String: String]
    }
}
