//
//  FacebookItemView.swift
//  Socialify
//
//  Created by Tomasz on 28/06/2021.
//

import SwiftUI

struct FacebookItemView: View {
    
    //var destination: TargetView
    //var title: String
    var icon: String
    
    var body: some View {
        Button(action: {} /*destination: destination*/) {
            VStack {
                HStack {
                    VStack {
                        Image(icon)
                            .resizable()
                            .clipShape(Circle())
                            //.overlay(Circle().stroke(Color("CustomAppearanceItemColor"), lineWidth: 1))
                            //.shadow(radius: 4)
                            .frame(width: 20 , height: 20)
                            .padding(.bottom, 14)
                    }
                    
                    
                        
                    VStack {
                        Text(LocalizedStringKey("Nazwa grupy"))
                            .bold()
                            .foregroundColor(Color("CustomForegroundColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 20))
                            
                        
                        Text(LocalizedStringKey("Kto dodał - kiedy dodał"))
                            .foregroundColor(Color("CustomForegroundColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 10, design: .monospaced))
                        
                    }
                }
                
                Divider()
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin nibh augue, suscipit a, scelerisque sed, lacinia in, mi. Cras vel lorem. Etiam pellentesque aliquet tellus. Phasellus pharetra nulla ac diam. Quisque semper justo at risus. Donec venenatis, turpis vel hendrerit interdum, dui ligula ultricies purus, sed posuere libero dui id orci.")
                    .font(.caption)
                    .foregroundColor(Color("CustomForegroundColor"))
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)
                
                Image("mata")
                    .resizable()
                    .cornerRadius(8)
                    //.fixedSize()
                    .padding(2)
                    .shadow(radius: 1)
                    
                    .frame(maxWidth: .infinity, maxHeight: 170)
                
                Divider()
                
                HStack {
                    Text("Reakcje")
                        .foregroundColor(Color("CustomForegroundColor"))
                        .font(.system(size: 10, design: .monospaced))
                        .padding(.leading, 16)
                        .padding(.vertical, 2)
                    
                    Spacer()
                    
                    Text("Liczba komentarzy")
                        .foregroundColor(Color("CustomForegroundColor"))
                        .font(.system(size: 10, design: .monospaced))
                        .padding(.trailing, 6)
                        .padding(.vertical, 2)
                    
                }.frame(maxWidth: .infinity)
                
                Divider()
                
                HStack {
                    Label("Like", systemImage: "hand.thumbsup")
                        .foregroundColor(Color("CustomForegroundColor"))
                        .font(.system(size: 12))
                        .padding(.leading, 46)
                    
                    Spacer()
                    
                    Label("Comment", systemImage: "text.bubble")
                        .foregroundColor(Color("CustomForegroundColor"))
                        .font(.system(size: 12))
                        .padding(.trailing, 40)
                }
            }
            Spacer()
            
        }
        .font(.headline)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("CustomAppearanceItemColor"))
        .cornerRadius(10)
    }
}

struct FacebookItemView_Previews: PreviewProvider {
    static var previews: some View {
        FacebookItemView(/*title: "Dupa",*/ icon: "Facebook")
    }
}
