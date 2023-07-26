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
                          ListFilterState.found.displayText,
                          ListFilterState.notFound.displayText],
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
}

struct RemainingPlatesView_Previews: PreviewProvider {    
    static var previews: some View {
        VStack {
            FilterSelectorView().environmentObject(AppModel(dataStore: MockDataStore()))
        }
    }
}
