//
//  StateView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import SwiftUI

struct LicensePlateView: View {
    @EnvironmentObject var model: AppModel
    
    // The license plate info to display
    let plateModel: LicensePlateModel
    
    var body: some View {
            HStack {
                Image(plateModel.plate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .cornerRadius(6.0)
                    .opacity(plateModel.found ? 0.5 : 1.0)
                Spacer()
                Text(plateModel.dateDisplay)
                    .font(.appText)
                    .foregroundColor(Color.appSubtext)
                Spacer()
                Image(systemName: plateModel.found ? "checkmark.circle.fill" : "checkmark.circle")
                    .resizable()
                    .foregroundColor(plateModel.found ? Color("AccentColor") : Color.appSubtext)
                    .frame(width: 36, height: 36)
            }
            .padding([.horizontal])
            .padding([.vertical], 8.0)
            .background(Color.appCardBackground).clipShape(RoundedRectangle(cornerRadius: 16.0))
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 16.0)
                    .stroke(lineWidth: 1.0)
                    .foregroundColor(plateModel.found ? Color.accentColor : .appSubtext))
    }
    
    func foundDateString(_ date: Date?) -> String {
        date?.formatted(date: .long, time: .omitted) ?? ""
    }
}

struct StateView_Previews: PreviewProvider {
    // Pretty sure there's a better way to do this.
    // Too lazy to figure it out right now.
    static let mockPlates = MockDataStore().fetch()
    static var sc:LicensePlateModel = mockPlates[0]
    static var ma:LicensePlateModel = mockPlates[1]
    static var la:LicensePlateModel = mockPlates[2]
    static var dc:LicensePlateModel = mockPlates[3]
    static var wi:LicensePlateModel = mockPlates[4]
    static var il:LicensePlateModel = mockPlates[5]
    static let appModel = AppModel(dataStore: MockDataStore())
    
    static var previews: some View {
        VStack(spacing: 24.0) {
            LicensePlateView(plateModel: sc).environmentObject(appModel)
            LicensePlateView(plateModel: ma).environmentObject(appModel)
            LicensePlateView(plateModel: la).environmentObject(appModel)
            LicensePlateView(plateModel: dc).environmentObject(appModel)
            LicensePlateView(plateModel: wi).environmentObject(appModel)
            LicensePlateView(plateModel: il).environmentObject(appModel)
        }
    }
}
