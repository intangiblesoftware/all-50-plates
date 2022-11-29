//
//  StateView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import SwiftUI

struct LicensePlateView: View {
    // The license plate info to display
    @ObservedObject var plateModel: LicensePlateViewModel
    
    var body: some View {
        VStack {
            HStack {
                plateModel.licensePlateImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .cornerRadius(6.0)
                    .opacity(plateModel.found ? 0.5 : 1.0)
                VStack(alignment: .leading) {
                    Text(plateModel.stateName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.8)
                        .lineLimit(correctLineLimit())
                        .foregroundColor(plateModel.found ? Color("FoundText") : Color("MainText"))
                        .truncationMode(.tail)
                    Text(plateModel.dateFoundString)
                        .font(.footnote)
                        .foregroundColor(plateModel.found ? Color("FoundText") : Color("MainText"))
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
                    plateModel.found.toggle()
                }
            }
        }
        .listRowBackground(Color("CellBackground"))
    }
    
    func foundDateString(_ date: Date?) -> String {
        date?.formatted(date: .long, time: .omitted) ?? ""
    }
    
    // I want the UI to break when there are 2 words in the state name,
    // but just shrink the text to fit when the name is too long to fit. 
    func correctLineLimit() -> Int {
        let wordCount = plateModel.stateName.split(separator: " ")
        return wordCount.count > 1 ? 2 : 1
    }
}

struct StateView_Previews: PreviewProvider {
    // Pretty sure there's a better way to do this.
    // Too lazy to figure it out right now.
    static let dataStore = MockDataStore()
    static var sc:LicensePlate = dataStore.licensePlates[0]
    static var ma:LicensePlate = dataStore.licensePlates[1]
    static var la:LicensePlate = dataStore.licensePlates[2]
    static var dc:LicensePlate = dataStore.licensePlates[3]
    static var wi:LicensePlate = dataStore.licensePlates[4]
    static var il:LicensePlate = dataStore.licensePlates[5]

    static var previews: some View {
        Group {
            VStack {
                LicensePlateView(plateModel: LicensePlateViewModel(with: sc, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: ma, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: la, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: dc, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: wi, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: il, in: dataStore))
            }
            .preferredColorScheme(.light)
            .previewDevice(PreviewDevice.init(stringLiteral: "iPhone SE"))
            VStack {
                LicensePlateView(plateModel: LicensePlateViewModel(with: sc, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: ma, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: la, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: dc, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: wi, in: dataStore))
                LicensePlateView(plateModel: LicensePlateViewModel(with: il, in: dataStore))
            }
            .preferredColorScheme(.dark)
            .previewDevice(PreviewDevice.init(stringLiteral: "iPhone 12 Pro"))
        }
    }
}
