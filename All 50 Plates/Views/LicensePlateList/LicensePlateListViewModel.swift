//
//  LicensePlateListViewModel.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation

enum ListFilterState: String {
    case allPlates = "allPlates"
    case found = "found"
    case notFound = "notFound"
}

class LicensePlateListViewModel: ObservableObject {
    var dataStore: LicensePlateStore
    
    @Published var licensePlates: [LicensePlate]
    
    @Published var filterState: ListFilterState {
        didSet {
            // Saving to user defaults every time it changes
            UserDefaults.standard.set(filterState.rawValue, forKey: Key.UserDefaults.listState)
            
            // And re-filter our list
            filterLicensePlates()
        }
    }
    
    @Published var gameWon: Bool = false
    
    @Published var numberRemaining: Int = 0
    
    init(with dataStore: LicensePlateStore) {
        self.dataStore = dataStore
        
        self.licensePlates = dataStore.licensePlates
        
        // Get old filtered state from user defaults if it exists.
        // Setting filter state will also filter the license plates array.
        let isFiltered = UserDefaults.standard.value(forKey: Key.UserDefaults.listIsFiltered) as? Bool ?? false
        if isFiltered {
            // Trying to preserve the state for users upgrading
            // If they have a saved list that's filtered, I'm gonna preserve that
            // But I'm getting rid of that user default and using the listState instead
            filterState = .notFound
        } else {
            // Initialize to all plates if we don't have a user default
            if let listStateRawValue = UserDefaults.standard.object(forKey: Key.UserDefaults.listState) as? String {
                filterState = ListFilterState(rawValue: listStateRawValue) ?? .allPlates
            } else {
                filterState = .allPlates
            }
        }
        
        // Now count the unfound ones
        numberRemaining = countRemaining()
        
        // And figure out if they won the game
        gameWon = numberRemaining <= 0

    }
    
    private func countRemaining() -> Int {
        return licensePlates.reduce(0) { partialResult, statePlate in
            partialResult + (statePlate.found ? 0 : 1)
        }
    }
    
    private func filterLicensePlates() {
        switch filterState {
        case .found:
            licensePlates = dataStore.licensePlates.filter { !$0.found }
        case .notFound:
            licensePlates = dataStore.licensePlates.filter { $0.found }
        case .allPlates:
            licensePlates = dataStore.licensePlates
        }
    }
    
    func reset() {
        // Resets the data model
        
    }
}
