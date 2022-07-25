//
//  AddRoomView.swift
//  AddRoomView
//
//  Created by Tomasz on 09/08/2021.
//

import SwiftUI
import SocialifySdk

struct AddGroupView: View {
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
                
                Text("Add Group")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
            }.padding(.vertical)
                .padding(.top, 20)
            
            VStack {
                NavigationLink("Create group", destination: CreateGroupView())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColor"))
                    .cornerRadius(12)
                
                NavigationLink("Join to existing group", destination: JoinToGroupView())
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
        .background(Color("BackgroundColor"))
        .onAppear() {
            Global.tabBar!.isHidden = true
        }
    }
}
//
//struct AddRoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddRoomView()
//    }
//}
