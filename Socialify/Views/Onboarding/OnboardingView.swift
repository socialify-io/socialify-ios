//
//  OnboardingView.swift
//  Socialify
//
//  Created by Tomasz on 28/03/2021.
//

import SwiftUI

fileprivate struct InformationDetailView: View {
    var title: LocalizedStringKey = ""
    var subtitle: LocalizedStringKey = ""
    var imageName: String = ""
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.system(size: 50))
                .font(.largeTitle)
                .frame(width: 50)
                .foregroundColor(.accentColor)
                .padding()
                .accessibility(hidden: true)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .lineLimit(2)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

struct OnboardingView: View {
    @AppStorage("needsAppOnboarding") private var needsAppOnboarding: Bool = true

    var body: some View {
        VStack {
            Spacer()
            Image("LaunchIcon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .foregroundColor(.accentColor)
            
            Text("onboarding.title")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
                .multilineTextAlignment(.center)
                .frame(height: 100)
            
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    InformationDetailView(title: "onboarding.functionality.title", subtitle: "onboarding.functionality.content", imageName: "command")
                    
                    InformationDetailView(title: "onboarding.storage.title", subtitle: "onboarding.storage.content", imageName: "externaldrive")
                    
                    InformationDetailView(title: "onboarding.cross.platform.title", subtitle: "onboarding.cross.platform.content", imageName: "laptopcomputer.and.iphone")
                    
                }.multilineTextAlignment(.leading)
                Spacer()
            }
            Spacer()
            Spacer()
            CustomButtonView(action: {
                needsAppOnboarding = false
            }, title: "onboarding.continue").padding(.bottom)
        }.padding(.horizontal)
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView()
        }
    }
}
