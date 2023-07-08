//
//  RemainingPlatesView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/23/21.
//

import SwiftUI

struct FilterSelectorView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ViewBackground(color: Color.appDark) {
            Picker("Plates", selection: $model.filterState) {
                Text("All Plates").tag(ListFilterState.allPlates)
                Text("Left to Find").tag(ListFilterState.notFound)
                Text("Found").tag(ListFilterState.found)
            }
            .padding(4.0)
            .font(Font.appControl).foregroundColor(.green)
            .colorMultiply(Color("AccentColor"))
            .background(Color.appDark)
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    /*
    func message() -> String {
        var message = ""
        let numberFound = numberOfPlates - numberRemaining
        
        switch platesToView {
        case .allPlates:
            switch numberRemaining {
            case 0: message = "You found them all! Congratulations!"
            case 1: message = "You have one plate left to find."
            default: message = "You have \(numberRemaining) license plates left to find."
            }

        case .found:
            switch numberRemaining {
            case 0: message = "You found all \(numberOfPlates) plates! Congratulations!"
            case numberOfPlates: message = "You haven't found any so far."
            default: message = "You found \(numberFound) so far."
            }

        case .notFound:
            switch numberRemaining {
            case 0: message = "You found them all! Congratulations!"
            case 1: message = "You have one plate left to find."
            default: message = "You have \(numberRemaining) license plates left to find."
            }
        }
        return message
    }
     */
}

struct RemainingPlatesView_Previews: PreviewProvider {    
    static var previews: some View {
        VStack {
            FilterSelectorView().environmentObject(AppModel(dataStore: MockDataStore()))
            FilterSelectorView().environmentObject(AppModel(dataStore: MockDataStore()))
            FilterSelectorView().environmentObject(AppModel(dataStore: MockDataStore()))
        }
    }
}
