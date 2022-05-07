//
//  SendImageView.swift
//  Socialify
//
//  Created by Tomasz on 01/05/2022.
//

import SwiftUI
import SocialifySdk
import CoreData

struct SendImageView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    
    let chatId: Int64
    
    @Binding var message: String
    @Binding var image: UIImage?
    @Binding var isImagePicked: Bool
    
    let cellHeight: CGFloat = 42
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("CustomAppearanceItemColor")
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Image(uiImage: image!)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Spacer()
            
           HStack {
                TextField("Text here...", text: $message)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                        
                
                Spacer()
            }.padding(.bottom)
            
            HStack {
                Button(action: { isImagePicked = false }) {
                    Image(systemName: "arrow.down.app")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color("CustomForegroundColor"))
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "crop")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.leading)
                    
                    Image(systemName: "crop.rotate")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "camera.filters")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                    
                }.frame(height: cellHeight)
                .background(cellBackground)
                .cornerRadius(cornerRadius)
               
                Spacer()
                
                Button(action: {
                    SocketIOManager.sharedInstance.sendDM(message: message, id: chatId, image: image)
                    message = ""
                    isImagePicked = false
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                }
            }.padding(.horizontal)
            
            
        }.padding()
        .background(Color("BackgroundColor"))
    }
}
