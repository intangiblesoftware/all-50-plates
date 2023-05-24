//
//  SettingsView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/23/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Button {
                
            } label: {
                Text("Reset Game?").foregroundColor(.white).fontWeight(.bold)
            }.padding()
                .background(Color("ButtonColor"))
                .clipShape(Capsule())

            Text("This will reset the game back to the beginning, unfinding all your found license plates.").font(.caption).multilineTextAlignment(.center)
                .padding([.leading, .trailing], 40)
            Spacer()
            CompanyView(title: "App created & coded\nby Jim Dabrowski",
                        imageName: "intangibleLogo",
                        companyName: "Intangible Software",
                        companyLink: "https://intangiblesoftware.com")
            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct CompanyView: View {
    let title: String
    let imageName: String
    let companyName: String
    let companyLink: String
    
    var body: some View {
        Text(title)
            .font(.body)
            .multilineTextAlignment(.center)
            .padding([.leading, .trailing])
        Image(imageName)
            .resizable()
            .frame(width: 75, height: 75)
        Text(companyName)
            .font(.body).fontWeight(.bold)
            .padding(.bottom)
        Text(companyLink)
            .font(.body)
            .foregroundColor(Color("AccentColor"))

    }
}
