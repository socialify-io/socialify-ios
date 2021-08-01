//
//  ErrorReportView.swift
//  ErrorReportView
//
//  Created by Tomasz on 31/07/2021.
//

import SwiftUI

struct ErrorReportView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var showErrorReportModal: Bool
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    
    @State private var title = ""
    @State private var message = ""
    
    @State private var buttonText = "Report"
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Image("LaunchIcon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 160)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, -40)
                
                Text("Report a problem")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
            }.padding(.top, -40)
            
            Spacer()
            
            VStack {
                TextField(LocalizedStringKey("Title"), text: $title)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                
                ZStack(alignment: .top) {
                    if message.isEmpty {
                        Text("Message")
                            .foregroundColor(Color(UIColor.systemGray))
                            .padding(9)
                    }
                    
                    TextEditor(text: $message)
                        .autocapitalization(.none)
                        .font(Font.body.weight(Font.Weight.medium))
                        .multilineTextAlignment(.center)
                        .frame(height: cellHeight*3)
                        .cornerRadius(cornerRadius)
                }
                
               Label("All fields are optional.", systemImage: "info.circle")
                    .padding()
                    .font(.callout)
                    .foregroundColor(Color.accentColor)
                
            }.padding(.bottom, 40)
            
            Spacer()
            
            CustomButtonView(action: {
                print("Reporting a problem...")
            }, title: buttonText)
            .padding(.bottom)
            
            Button(action: {
                self.presentationMode.projectedValue.wrappedValue.dismiss()
                self.showErrorReportModal = false
            }) {
                Text("Nevermind")
                    .padding(.bottom)
            }
            .padding(.bottom)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            UITextView.appearance().backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
        }
    }
}

struct ErrorReportView_Previews: PreviewProvider {
    
    static var previews: some View {
        ErrorReportView(showErrorReportModal: .constant(true))
    }
}
