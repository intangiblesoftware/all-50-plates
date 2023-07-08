//
//  GameProgressView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 6/26/23.
//

import SwiftUI

struct GameProgressView: View {
    @EnvironmentObject var model: AppModel

    var progress: Float {
        switch model.filterState {
            case .allPlates, .found:
                return Float(model.numberFound) / Float(model.totalPlates)
            case .notFound:
                return Float(model.numberRemaining) / Float(model.totalPlates)
        }
    }
    
    var message: Text {
        switch model.filterState {
            case .allPlates, .found:
                return Text("\(model.numberFound) of \(model.totalPlates) found")
            case .notFound:
                return Text("\(model.numberRemaining) of \(model.totalPlates) left to find")
        }
    }
    
    var body: some View {
        ViewBackground(color: Color.appDark) {
            VStack {
                ProgressView(value: progress)
                    .frame(height: 8)
                    .scaleEffect(x: 1, y: 4.0, anchor: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                HStack {
                    message.font(Font.appControl).foregroundColor(Color.appLight)
                    Spacer()
                }
            }.padding([.leading, .trailing], 16.0)
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        GameProgressView().environmentObject(AppModel(dataStore: MockDataStore()))
    }
}
