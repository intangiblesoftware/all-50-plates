//
//  AboutView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/23/23.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var model: AppModel
    
    let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.y.z"
    
    @State var developerToolsShowing: Bool = false
    @State var resetAlertIsShowing: Bool = false
    
    var body: some View {
        ViewBackground(color: .appBackground) {
            VStack (alignment: .center) {
                HStack {
                    Text("About").font(Font.appLargeTitle).textCase(.uppercase).foregroundColor(.appLight)
                    Spacer()
                    Button {
                        model.aboutIsShowing = false
                    } label: {
                        Label("Done", systemImage: "xmark").labelStyle(.titleOnly)
                    }
                }.padding([.leading, .trailing, .top], 16.0).background(Color.appDark)
                VStack {
                    ScrollView {
                        List {
                            AboutListCell(title: "Version", value: appVersion)
                            AboutListCell(title: "Author", value: "Jim Dabrowski")
                            AboutListCell(title: "Design", value: "Eric Ziegler")
                        }.frame(height: 200).scrollContentBackground(.hidden)
                            
                        Text("Copyright © 2023").font(.appParagraph)
                        HStack {
                            CompanyView(imageName: "intangibleLogo",
                                        companyName: "Intangible Software",
                                        companyLink: "https://intangiblesoftware.com",
                                        linkText: "intangiblesoftware.com")
                            Spacer()
                            CompanyView(imageName: "lpSoftwareLogo",
                                        companyName: "Logical Pixels Design",
                                        companyLink: "https://logicalpixels.com",
                                        linkText: "logicalpixels.com")
                        }.padding()
                    }
                }
                Spacer()
                Button {
                    resetAlertIsShowing = true
                } label: {
                    Text("Reset Game")
                        .font(.appAction)
                        .textCase(.uppercase)
                        .foregroundColor(.appButtonText)
                        .frame(width: 275.0, height: 55.0)
                }.background(Color("AccentColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .circular))
                    .alert("Are you sure you want to reset your game?", isPresented: $resetAlertIsShowing) {
                        Button("Reset", role: .destructive) {
                            model.reset()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                Text("This will reset the game back to the beginning, unfinding all your found license plates.").font(.appParagraph).foregroundColor(.appText).multilineTextAlignment(.center).frame(maxWidth: 275)
                Spacer()
#if DEBUG
//                renderDeveloperTools()
#endif
                
            }.sheet(isPresented: $developerToolsShowing) {
                DeveloperToolsView()
            }
        }
    }
    
    @ViewBuilder private func renderDeveloperTools() -> some View {
        Button {
            developerToolsShowing = true
        } label: {
            Label {
                Text("Developer Tools")
            } icon: {
                Image(systemName: "wrench.and.screwdriver.fill")
            }
            
        }
    }
    
}

struct AboutListCell: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).font(Font.appText).foregroundColor(.appText).textCase(.uppercase)
            Spacer()
            Text(value).multilineTextAlignment(.trailing).font(.appText).foregroundColor(.appSubtext)
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
                .font(Font.appControl)
                .foregroundColor(.appText)
            Link(linkText, destination: URL(string: companyLink)!)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.appText)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView().environmentObject(AppModel(dataStore: MockDataStore()))
    }
}
