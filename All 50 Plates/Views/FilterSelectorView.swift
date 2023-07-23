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
            SegmentsView([ListFilterState.allPlates.displayText,
                          ListFilterState.notFound.displayText,
                          ListFilterState.found.displayText],
                         selectedIndex: Binding<Int>(
                            get: { model.filterState.rawValue },
                            set: { newValue in model.filterState = ListFilterState(rawValue: newValue) ?? .allPlates }
                         ),
                         backgroundColor: .appLight,
                         selectedBackgroundColor: .accentColor,
                         textColor: .appGray,
                         selectedTextColor: .appDark,
                         font: .appControl)
            .frame(height: 32)
            .padding()
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
        }
    }
}
