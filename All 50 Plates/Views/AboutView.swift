//
//  AboutView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/23/23.
//

import SwiftUI

struct AboutView: View {
    @ObservedObject var model: AppModel
    @Binding var isShowing: Bool
    
    @State private var alertIsShowing: Bool = false
    
    var body: some View {
        VStack (alignment: .center, spacing: 16) {
            Spacer()
            Text("About")
            List { 
                AboutListCell(title: "Version", value: "1.2.0")
                AboutListCell(title: "Author", value: "Jim Dabrowski")
                AboutListCell(title: "Design", value: "Eric Ziegler")
            }
            List {
                Text("Copyright © 2023").font(ISFont.paragraph)
                HStack {
                    CompanyView(imageName: "intangibleLogo",
                                companyName: "Intangible Software",
                                companyLink: "https://intangiblesoftware.com",
                                linkText: "intangiblesoftware.com")
                    .padding([.trailing], 16)
                    CompanyView(imageName: "lpSoftwareLogo", companyName: "Logical Pixels Design", companyLink: "https://logicalpixels.com", linkText: "logicalpixels.com")
                }
                Button {
                    alertIsShowing = true
                } label: {
                    Text("RESET GAME").font(ISFont.action).foregroundColor(Color("ButtonText"))
                }.frame(width: 275.0, height: 55.0)
                    .background(Color("AccentColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .circular))
                Text("This will reset the game back to the beginning, unfinding all your found license plates.").font(ISFont.paragraph).multilineTextAlignment(.center).frame(maxWidth: 275)
            }.listStyle(.plain)
            Spacer()
        }
    }
}

struct AboutListCell: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).font(ISFont.about).foregroundColor(Color("MainText"))
            Spacer()
            Text(value).multilineTextAlignment(.trailing).font(ISFont.about).foregroundColor(Color("SubHeadingText"))
        }
    }
}

struct CompanyView: View {
    let imageName: String
    let companyName: String
    let companyLink: String
    let linkText: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            Text(companyName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("MainText"))
            Link(linkText, destination: URL(string: companyLink)!)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("MainText"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let appModel: AppModel = AppModel(dataStore: MockDataStore())
    @State static var isShowing = true
    static var previews: some View {
        AboutView(model: appModel, isShowing: $isShowing)
    }
}
