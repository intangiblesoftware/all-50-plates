//
//  SettingsView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/23/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel
    @Binding var isShowing: Bool
    
    @State private var alertIsShowing: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button {
                    isShowing = false
                } label: {
                    Text("Done")
                }
                .padding([.trailing, .top], 16)
            }

            Spacer()
            Button {
                alertIsShowing = true
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
        }.alert("Reset Game?", isPresented: $alertIsShowing) {
            Button(role: .destructive) {
                model.reset()
                alertIsShowing = false
                isShowing = false
            } label: {
                Text("Reset")
            }
            Button(role: .cancel) {
                alertIsShowing = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("This will reset the game back to the start. Are you sure you want to do this?")
        }

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
            .foregroundColor(Color("MainText"))
            .multilineTextAlignment(.center)
            .padding([.leading, .trailing])
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
        Text(companyName)
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(Color("MainText"))
            .padding(.bottom, 4)
        Link(companyLink, destination: URL(string: companyLink)!)
            .font(.body)
            .foregroundColor(Color("AccentColor"))
            .padding(.bottom, 48)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let appModel: AppModel = AppModel(dataStore: MockDataStore())
    @State static var isShowing = true
    static var previews: some View {
        SettingsView(model: appModel, isShowing: $isShowing)
    }
}
