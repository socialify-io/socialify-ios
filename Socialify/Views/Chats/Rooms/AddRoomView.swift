//
//  AddRoomView.swift
//  AddRoomView
//
//  Created by Tomasz on 09/08/2021.
//

import SwiftUI
import SocialifySdk

struct AddRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    
    var body: some View {
        VStack {
            VStack {
                Image("SocialifyIcon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 160)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, -40)
                
                Text("Add Room")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
            }.padding(.vertical)
                .padding(.top, 20)
            
            VStack {
                NavigationLink("Create room", destination: CreateRoomView())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColor"))
                    .cornerRadius(12)
                
                NavigationLink("Join to room", destination: JoinToRoomView())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColor"))
                    .cornerRadius(12)
                
            }.padding(.vertical)
                .padding(.top, 40)
        
            
            Spacer()
        }.padding()
    }
}

struct AddRoomView_Previews: PreviewProvider {
    static var previews: some View {
        AddRoomView()
    }
}