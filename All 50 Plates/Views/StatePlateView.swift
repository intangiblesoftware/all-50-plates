//
//  StateView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import SwiftUI
import Combine

struct StatePlateView: View {
    // The statePlate to display
    var statePlate: StatePlate
    
    var body: some View {
        VStack {
            HStack {
                Image(decorative: statePlate.plate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .cornerRadius(6.0)
                VStack(alignment: .leading) {
                    Text(statePlate.state)
                        .font(.title2)
                        .fontWeight(.bold)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.9)
                        .lineLimit(correctLineLimit())
                        .foregroundColor(statePlate.found ? .gray : .black)
                    Text(statePlate.date ?? "")
                        .font(.footnote)
                        .foregroundColor(statePlate.found ? .gray : .black)
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
//                    statePlate.found.toggle()
                    if statePlate.found {
                       let dateFound = Date()
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateStyle = .long
                       dateFormatter.timeStyle = .none
                       dateFormatter.locale = .current
                        statePlate.date = dateFormatter.string(from: dateFound)
                   } else {
                    statePlate.date = ""
                   }
                }
            }
        }
    }
    
    func correctLineLimit() -> Int {
        let wordCount = statePlate.state.split(separator: " ")
        return wordCount.count > 1 ? 2 : 1
    }
}

struct StateView_Previews: PreviewProvider {
    static var sc:StatePlate = StatePlate(state: "South Carolina", plate: "SC", found: true, date: "September 5, 2021")
    static var ma:StatePlate = StatePlate(state: "Massachusetts", plate: "MA", found: false, date: "December 31, 2021")
    static var la:StatePlate = StatePlate(state: "Louisianna", plate: "LA", found: false, date:"")
    static var previews: some View {
        VStack {
            StatePlateView(statePlate: sc)
            StatePlateView(statePlate: ma)
            StatePlateView(statePlate: la)
        }
    }
}
