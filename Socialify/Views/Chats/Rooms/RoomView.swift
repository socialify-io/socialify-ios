//
//  RoomView.swift
//  RoomView
//
//  Created by Tomasz on 10/08/2021.
//

import SwiftUI
import SocialifySdk

struct RoomView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let roomId: Int
    
    var body: some View {
        Text("Hello, World!")
    }
}
//
//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView(roomId: 0)
//    }
//}
