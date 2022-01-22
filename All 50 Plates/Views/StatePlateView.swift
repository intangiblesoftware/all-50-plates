//
//  StateView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import SwiftUI

struct StatePlateView: View {
    // The statePlate to display
    @ObservedObject var statePlate: StatePlate
    
    let notificationCenter = NotificationCenter.default
        
    var body: some View {
        VStack {
            HStack {
                Image(decorative: statePlate.plate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .cornerRadius(6.0)
                    .opacity(statePlate.found ? 0.5 : 1.0)
                VStack(alignment: .leading) {
                    Text(statePlate.state)
                        .font(.title2)
                        .fontWeight(.bold)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.9)
                        .lineLimit(correctLineLimit())
                        .foregroundColor(statePlate.found ? Color("FoundText") : Color("MainText"))
                    Text(statePlate.date ?? "")
                        .font(.footnote)
                        .foregroundColor(statePlate.found ? Color("FoundText") : Color("MainText"))
                }
                Spacer()
                if statePlate.found {
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
                    statePlate.found.toggle()
                    notificationCenter.post(name: .statePlateUpdated, object: nil)
                }
            }
        }
        .listRowBackground(Color("CellBackground"))
    }
    
    // I want the UI to break when there are 2 words in the state name,
    // but just shrink the text to fit when the name is too long to fit. 
    func correctLineLimit() -> Int {
        let wordCount = statePlate.state.split(separator: " ")
        return wordCount.count > 1 ? 2 : 1
    }
}

struct StateView_Previews: PreviewProvider {
    static var sc:StatePlate = StatePlate(state: "South Carolina", plate: "SC", found: true, date: "September 5, 2021")
    static var ma:StatePlate = StatePlate(state: "Massachusetts", plate: "MA", found: false, date: "December 31, 2021")
    static var la:StatePlate = StatePlate(state: "Louisianna", plate: "LA", found: false, date:"")
    static var dc:StatePlate = StatePlate(state: "Washington D.C.", plate: "DC", found: false, date:"")
    static var previews: some View {
        Group {
            VStack {
                StatePlateView(statePlate: sc)
                StatePlateView(statePlate: ma)
                StatePlateView(statePlate: la)
                StatePlateView(statePlate: dc)
            }
            .preferredColorScheme(.light)
            .previewDevice(PreviewDevice.init(stringLiteral: "iPhone SE"))
            VStack {
                StatePlateView(statePlate: sc)
                StatePlateView(statePlate: ma)
                StatePlateView(statePlate: la)
                StatePlateView(statePlate: dc)
            }
            .preferredColorScheme(.dark)
            .previewDevice(PreviewDevice.init(stringLiteral: "iPhone 12 Pro"))
        }
    }
}
