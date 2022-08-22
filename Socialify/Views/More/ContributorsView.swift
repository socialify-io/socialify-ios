//
//  ContributorsView.swift
//  Socialify
//
//  Created by Tomasz on 13/05/2022.
//

import SwiftUI

struct ContributorsView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        Form {
            HStack {
                AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/55411338?s=460&v=4")!,
                               placeholder: { Image(systemName: "circle.dashed") },
                               image: { Image(uiImage: $0).resizable() })
                    .frame(width: 38, height: 38)
                    .cornerRadius(10)
                Link("Pengwius", destination: URL(string: "https://github.com/pengwius")!)
                    .foregroundColor(Color("CustomForegroundColor"))
            }
        }.navigationBarTitle("App developers", displayMode: .inline)
        .background(Color("BackgroundColor"))
    }
}

struct ContributorsView_Previews: PreviewProvider {
    static var previews: some View {
        ContributorsView()
    }
}
