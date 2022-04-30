//
//  CreateRoomView.swift
//  Socialify
//
//  Created by Tomasz on 19/02/2022.
//

import SwiftUI
import SocialifySdk

struct CreateRoomView: View {
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @Environment(\.presentationMode) var presentationMode
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color("CustomAppearanceItemColor")
    let borderColor: Color = Color(UIColor.systemGray).opacity(0)
   
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .success
    
    @State private var clicked: Bool = false

    @State private var errorAlertShow: ErrorAlert?
    @State private var showErrorReportModal = false
    
    @State private var roomName = ""
    @State private var password = ""
    
    @State private var buttonText = "Create"
    
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
                
                Text("Create your room")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
            }.padding(.top, -40)
            
            Spacer()
            Spacer()
            
            VStack {
                TextField(LocalizedStringKey("Room name"), text: $roomName)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(setColor(input: roomName, clicked: clicked), lineWidth: 2)
                    )
            }.padding(.bottom, 60)
            
            Spacer()
            Spacer()
            
            CustomButtonView(action: {
                clicked = true
                if(roomName != ""){
                    SocketIOManager.sharedInstance.createRoom(roomName: roomName, password: password) { value in
                        switch(value){
                        case .success(let value):
                            self.activeAlert = .success
                            self.showAlert = true
                            
                        case .failure(let error):
                            errorAlertShow = ErrorAlert(name: "errors.default".localized, description: "errors.default_description".localized)
                        }
                    }
                }
            }, title: buttonText)
            .padding(.bottom)
        }.padding()
        .sheet(isPresented: $showErrorReportModal, onDismiss: {
            }) {
            NavigationView {
                ErrorReportView(showErrorReportModal: self.$showErrorReportModal)
                    .navigationBarTitle(Text("Back"))
                    .navigationBarHidden(true)
                    //.background(Color("BackgroundColor")).edgesIgnoringSafeArea(.bottom)
            }
        }
        .background(Color("BackgroundColor"))
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .success:
                return Alert(title: Text("success"), message: Text("You room has successfully created!"), dismissButton: .default(Text("got_it")){
                        DispatchQueue.main.async{
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    })
            case .failure:
                return Alert(title: Text(errorAlertShow?.name ?? "errors.default"), message: Text(errorAlertShow?.description ?? "errors.default_description"), primaryButton: .cancel(), secondaryButton: .destructive(Text("errors.button")) { self.showErrorReportModal = true } )
            }
        }
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
    }
}
