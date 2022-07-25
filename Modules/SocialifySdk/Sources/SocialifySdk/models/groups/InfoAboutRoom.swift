//
//  InfoAboutRoom.swift
//  
//
//  Created by Tomasz on 16/03/2022.
//

import Foundation

@available(iOS 14.0, *)
extension SocialifyClient {
    
//    public struct InfoAboutRoom {
//        public init(roomId: String,
//                    isPublic: Bool,
//                    roomName: String,
//                    roomMembers: [[String: Any]]
//        ) {
//            self.roomId = roomId
//            self.isPublic = isPublic
//            self.roomName = roomName
//            self.roomMembers = []
//
//            for member in roomMembers {
//                self.roomMembers.append(
//                    RoomMember(id: member["id"] as! String,
//                               username: member["username"] as! String,
//                               role: member["role"] as! Int
//                              )
//                )
//            }
//        }
//
//        public var roomId: String
//        public var isPublic: Bool
//        public var roomName: String
//        public var roomMembers: [RoomMember]
//    }
    
//    links = [{
//            "_id": str(x['_id']),
//            "linkName": x['linkName'],
//            "link": f'{url}/invite/{str(x["_id"])}',
//            "isAdminApprovalNeeded": x['isAdminApprovalNeeded'],
//            "isUnlimitedUses": x['isUnlimitedUses'],
//            "isExpiryDateSet": x['isExpiryDateSet'],
//            "uses": x['uses'],
//            "expiryDate": x['expiryDate'],
//            "usedTimes": x['usedTimes'],
//            "isForSpecialUsers": x["isForSpecialUsers"],
//            "specialUsers": x["specialUsers"]
//        } for x in group['inviteLinks']]
    
    public struct GroupLink: Identifiable {
        public init(id: String,
                    linkName: String?,
                    link: String,
                    isUnlimitedUses: Bool,
                    isExpiryDateSet: Bool,
                    uses: Int?,
                    usedTimes: Int,
                    expiryDate: String?) {
            self.id = id
            if (linkName != "") {
                self.linkName = linkName
            }
            self.link = URL(string: link)!
            self.isUnlimitedUses = isUnlimitedUses
            self.isExpiryDateSet = isExpiryDateSet
            self.uses = uses
            self.usedTimes = usedTimes
            if (isExpiryDateSet) {
                let dateFormatter = ISO8601DateFormatter()
                
                self.expiryDate = dateFormatter.date(from: expiryDate!)
            }
            
        }
        
        public var id: String
        public var linkName: String?
        public var link: URL
        public var isUnlimitedUses: Bool
        public var isExpiryDateSet: Bool
        public var uses: Int?
        public var usedTimes: Int
        public var expiryDate: Date?
    }
    
    public struct GroupMember: Identifiable {
        public init(id: String,
                    username: String,
                    role: Int
        ) {
            self.userId = id
            self.username = username
            self.role = parseGroupRole(roleId: role)
        }
        
        public var id: String {
            self.userId
        }
        public var userId: String
        public var username: String
        public var role: GroupRole
    }
    
    public struct GroupRoom: Identifiable {
        public init(id: String,
                    name: String,
                    type: Int) {
            self.id = id
            self.name = name
            self.type = parseRoomType(type: type)
        }
        
        public var id: String
        public var name: String
        public var type: RoomType
    }
    
    public struct RoomsSection: Identifiable {
        public init(id: String, name: String, rooms: [GroupRoom]) {
            self.id = id
            self.name = name
            self.rooms = rooms
        }
        
        public var id: String
        public var name: String
        public var rooms: [GroupRoom]
    }
    
    public enum RoomType {
        case text
        case voice
    }
    
    static func parseRoomType(type: Int) -> RoomType {
        switch type {
            case 1:     return RoomType.text
            case 2:     return RoomType.voice
                
            default:    return RoomType.text
        }
    }
    
    static public func parseFromRoomType(type: RoomType) -> Int {
        switch type {
            case RoomType.text:     return 1
            case RoomType.voice:    return 2
                
            default:                return 1
        }
    }
    
    public enum GroupRole {
        case admin
        case member
    }
    
    static func parseGroupRole(roleId: Int) -> GroupRole {
        switch roleId {
            case 1:     return GroupRole.admin
            case 2:     return GroupRole.member
            
            default:    return GroupRole.member
        }
    }
}
