//
//  ErrorReportView.swift
//  ErrorReportView
//
//  Created by Tomasz on 31/07/2021.
//

import SwiftUI
import SocialifySdk

struct ErrorReportView: View {
    
    @StateObject var client: SocialifyClient = SocialifyClient.shared
    @Binding var showErrorReportModal: Bool
    
    let cellHeight: CGFloat = 55
    let cornerRadius: CGFloat = 12
    let cellBackground: Color = Color(UIColor.systemGray5).opacity(0.5)
    
    @State private var title = ""
    @State private var message = ""
    
    @State private var buttonText = "errors.button"
    
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
                
                Text("error_report.title")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
            }.padding(.top, -40)
            
            Spacer()
            
            VStack {
                TextField(LocalizedStringKey("error_report.message_title_placeholder"), text: $title)
                    .autocapitalization(.none)
                    .font(Font.body.weight(Font.Weight.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: cellHeight)
                    .background(cellBackground)
                    .cornerRadius(cornerRadius)
                
                ZStack(alignment: .top) {
                    if message.isEmpty {
                        Text("error_report.message_placeholder")
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
                
               Label("error_report.optional_info", systemImage: "info.circle")
                    .padding()
                    .font(.callout)
                    .foregroundColor(Color.accentColor)
                
            }.padding(.bottom, 40)
            
            Spacer()
            
            CustomButtonView(action: {
                let report = SocialifyClient.ErrorReport(errorType: nil,
                                                         errorContext: nil,
                                                         messageTitle: title,
                                                         message: message)
                
                client.reportError(report: report) { result in
                    switch result {
                    case .success(let response):
                        self.showErrorReportModal = false
                        print(response)
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }, title: buttonText)
            .padding(.bottom)
            
            Button(action: {
                self.showErrorReportModal = false
            }) {
                Text("nevermind")
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
