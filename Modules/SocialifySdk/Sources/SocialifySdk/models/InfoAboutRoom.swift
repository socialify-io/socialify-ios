//
//  InfoAboutRoom.swift
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
                    roomMembers: [[String: Any]]
        ) {
            self.roomId = roomId
            self.isPublic = isPublic
            self.roomName = roomName
            self.roomMembers = []
            
            for member in roomMembers {
                self.roomMembers.append(
                    RoomMember(id: member["id"] as! Int,
                               username: member["username"] as! String,
                               role: member["role"] as! Int
                              )
                )
            }
        }
        
        public var roomId: Int
        public var isPublic: Bool
        public var roomName: String
        public var roomMembers: [RoomMember]
    }
    
    public struct RoomMember: Identifiable {
        public init(id: Int,
                    username: String,
                    role: Int
        ) {
            self.userId = id
            self.username = username
            self.role = parseRoomRole(roleId: role)
        }
        
        public var id: Int {
            self.userId
        }
        public var userId: Int
        public var username: String
        public var role: RoomRole
    }
    
    public enum RoomRole {
        case admin
        case member
    }
    
    static func parseRoomRole(roleId: Int) -> RoomRole {
        switch roleId {
            case 1:     return RoomRole.admin
            case 2:     return RoomRole.member
            
            default:    return RoomRole.member
        }
    }
}
