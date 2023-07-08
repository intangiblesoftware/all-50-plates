//
//  AboutView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/23/23.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var model: AppModel
    
    @State var developerToolsShowing: Bool = false
    
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
                    List {
                        AboutListCell(title: "Version", value: "1.2.0").listRowSeparatorTint(.appDark)
                        .alignmentGuide(.listRowSeparatorLeading) { d in
                            d[.leading]
                        }.alignmentGuide(.listRowSeparatorTrailing) { d in
                            d[.trailing]
                        }.listRowSeparatorTint(.appDark)
                        AboutListCell(title: "Author", value: "Jim Dabrowski").listRowSeparator(.hidden, edges: .bottom)
                        HStack {
                            Spacer()
                            CompanyView(imageName: "intangibleLogo",
                                        companyName: "Intangible Software",
                                        companyLink: "https://intangiblesoftware.com",
                                        linkText: "intangiblesoftware.com")
                            Spacer()
                        }.alignmentGuide(.listRowSeparatorLeading) { d in
                            d[.leading]
                        }.alignmentGuide(.listRowSeparatorTrailing) { d in
                            d[.trailing]
                        }.listRowSeparatorTint(.appDark)
                        AboutListCell(title: "Design", value: "Eric Ziegler").listRowSeparator(.hidden, edges: .bottom)
                        HStack {
                            Spacer()
                            CompanyView(imageName: "lpSoftwareLogo",
                                        companyName: "Logical Pixels Design",
                                        companyLink: "https://logicalpixels.com",
                                        linkText: "logicalpixels.com")
                            Spacer()
                        }.alignmentGuide(.listRowSeparatorLeading) { d in
                            d[.leading]
                        }.alignmentGuide(.listRowSeparatorTrailing) { d in
                            d[.trailing]
                        }.listRowSeparatorTint(.appDark)
                        HStack {
                            Spacer()
                            Text("Copyright © 2023").font(.appParagraph).foregroundColor(.appText)
                            Spacer()
                        }.listRowSeparator(.hidden, edges: .bottom)
                    }.scrollContentBackground(.hidden)
                }
                Button {
                    //model.reset()
                } label: {
                    Text("Reset Game").font(.appAction).textCase(.uppercase).foregroundColor(.appText)
                }.frame(width: 275.0, height: 55.0)
                    .background(Color("AccentColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .circular))
                Text("This will reset the game back to the beginning, unfinding all your found license plates.").font(.appParagraph).foregroundColor(.appText).multilineTextAlignment(.center).frame(maxWidth: 275)
                Spacer()
#if DEBUG
                renderDeveloperTools()
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
