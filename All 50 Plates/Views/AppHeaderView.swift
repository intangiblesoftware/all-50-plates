//
//  AppHeaderView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 6/26/23.
//

import SwiftUI

struct AppHeaderView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ViewBackground(color: Color.appDark) {
            HStack{
                Group {
                    Text("All").foregroundColor(Color.appLight).padding([.leading], 16.0)
                    Text("50").foregroundColor(Color("AccentColor"))
                    Text("Plates").foregroundColor(Color.appLight)
                }.font(Font.appLargeTitle).textCase(.uppercase)
                Spacer()
                Button {
                    model.aboutIsShowing = true
                } label: {
                    Label("About", systemImage: "gear").labelStyle(.iconOnly).padding([.trailing], 16.0)
                }

            }
        }
    }
}

struct AppHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        AppHeaderView().environmentObject(AppModel(dataStore: MockDataStore()))
    }
}
