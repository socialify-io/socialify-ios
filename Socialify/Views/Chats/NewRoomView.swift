//
//  NewRoomView.swift
//  NewRoomView
//
//  Created by Tomasz on 09/08/2021.
//

import SwiftUI
import SocialifySdk

struct NewRoomView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    let borderColor: Color = Color(UIColor.systemGray).opacity(0)
    
    @State private var roomId = ""
    @State private var buttonText = "Join"
    
    @State private var clicked: Bool = false
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Image("SocialifyIcon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 160)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, -40)
                
                Text("Join to room")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
            }.padding(.top, -40)
            
            Spacer()
            Spacer()
            
            VStack {
                TextField(LocalizedStringKey("Room ID"), text: $roomId)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(setColor(input: roomId, clicked: clicked), lineWidth: 2)
                    )
            }.padding(.bottom, 60)
            
            Spacer()
            Spacer()
            
            CustomButtonView(action: {
                clicked = true
                SocketIOManager.sharedInstance.join(roomId: roomId)
            }, title: buttonText)
        }.padding()
    }
}

struct NewRoomView_Previews: PreviewProvider {
    static var previews: some View {
        NewRoomView()
    }
}
