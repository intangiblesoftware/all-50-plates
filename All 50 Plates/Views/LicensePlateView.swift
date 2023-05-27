//
//  StateView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import SwiftUI

struct LicensePlateView: View {
    // The license plate info to display
    let plateModel: LicensePlateModel
    let appModel: AppModel
    
    var body: some View {
        VStack {
            HStack {
                Image(plateModel.plate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .cornerRadius(6.0)
                    .opacity(plateModel.found ? 0.5 : 1.0)
                VStack(alignment: .leading) {
                    Text(plateModel.state)
                        .font(.title2)
                        .fontWeight(.bold)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.8)
                        .lineLimit(correctLineLimit())
                        .foregroundColor(plateModel.found ? Color("FoundText") : Color("MainText"))
                        .truncationMode(.tail)
                    if let plateDate = plateModel.date {
                        let dateFound = ISO8601DateFormatter().date(from: plateDate)
                        let dateString = foundDateString(dateFound)
                        Text(dateString)
                            .font(.footnote)
                            .foregroundColor(plateModel.found ? Color("FoundText") : Color("MainText"))
                    }
                }
                Spacer()
                if plateModel.found {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .foregroundColor(Color("AccentColor"))
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: "checkmark.seal")
                        .resizable()
                        .foregroundColor(Color("AccentColor"))
                        .frame(width: 36, height: 36)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .onTapGesture {
                withAnimation {
                    appModel.tapped(plate: plateModel)
                }
            }
        }
    }
    
    func foundDateString(_ date: Date?) -> String {
        date?.formatted(date: .long, time: .omitted) ?? ""
    }
    
    // I want the UI to break when there are 2 words in the state name,
    // but just shrink the text to fit when the name is too long to fit. 
    func correctLineLimit() -> Int {
        let wordCount = plateModel.state.split(separator: " ")
        return wordCount.count > 1 ? 2 : 1
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
        Group {
            VStack {
                LicensePlateView(plateModel: sc, appModel: appModel)
                LicensePlateView(plateModel: ma, appModel: appModel)
                LicensePlateView(plateModel: la, appModel: appModel)
                LicensePlateView(plateModel: dc, appModel: appModel)
                LicensePlateView(plateModel: wi, appModel: appModel)
                LicensePlateView(plateModel: il, appModel: appModel)
            }
            .preferredColorScheme(.light)
            .previewDevice(PreviewDevice.init(stringLiteral: "iPhone SE (3rd generation)"))
            VStack {
                LicensePlateView(plateModel: sc, appModel: appModel)
                LicensePlateView(plateModel: ma, appModel: appModel)
                LicensePlateView(plateModel: la, appModel: appModel)
                LicensePlateView(plateModel: dc, appModel: appModel)
                LicensePlateView(plateModel: wi, appModel: appModel)
                LicensePlateView(plateModel: il, appModel: appModel)
            }
            .preferredColorScheme(.dark)
            .previewDevice(PreviewDevice.init(stringLiteral: "iPhone 12 Pro"))
        }
    }
}
