//
//  LicensePlateListViewModel.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation
import Combine

class AppModel: ObservableObject {
    
    private let dataStore: LicensePlateStoreProtocol
    private let userDefaults = UserDefaults.standard
    private var allPlates: [LicensePlateModel] = []

    @Published var displayedPlates: [LicensePlateModel] = []
    @Published var totalPlates: Int = 0
    @Published var numberFound: Int = 0
    @Published var numberRemaining: Int = 0
    @Published var filterState: ListFilterState = .allPlates {
        didSet {
            refreshDisplayedPlates()
            userDefaults.set(filterState.rawValue, forKey: Key.UserDefaults.listState)
        }
    }
    @Published var aboutIsShowing: Bool = false

    init(dataStore: LicensePlateStoreProtocol) {
        self.dataStore = dataStore
        self.allPlates = dataStore.fetch()
                
        // Get old filtered state from user defaults if it exists.
        let isFiltered = userDefaults.value(forKey: Key.UserDefaults.listIsFiltered) as? Bool ?? false
        if isFiltered {
            // Trying to preserve the state for users upgrading
            // If they have a saved list that's filtered, I'm gonna preserve that
            // But I'm getting rid of that user default and using the listState instead
            filterState = .notFound
        } else {
            // Initialize to all plates if we don't have a user default
            if let listFilterStateRawValue = userDefaults.object(forKey: Key.UserDefaults.listState) as? Int {
                filterState = ListFilterState(rawValue: listFilterStateRawValue) ?? .allPlates
            } else {
                filterState = .allPlates
            }
        }

        refreshDisplayedPlates()
        updateCounts()
    }
    
    // MARK: - Private methods
    private func updateCounts() {
        totalPlates = countFor(state: .allPlates)
        numberFound = countFor(state: .found)
        numberRemaining = countFor(state: .notFound)
    }
    
    private func refreshDisplayedPlates() {
        displayedPlates.removeAll()
        switch self.filterState {
            case .allPlates:
                displayedPlates = allPlates
            case .found:
                displayedPlates = allPlates.filter { $0.found }
            case .notFound:
                displayedPlates = allPlates.filter { !$0.found }
        }
        sortPlates()
    }
    
    private func sortPlates() {
        displayedPlates.sort { $0.state < $1.state }
    }
    
    private func countFor(state: ListFilterState) -> Int {
        switch state {
            case .allPlates:
                return allPlates.count
            case .found:
                return allPlates.reduce(0) { partialResult, statePlate in
                    partialResult + (statePlate.found ? 1 : 0)
                }
            case .notFound:
                return allPlates.reduce(0) { partialResult, statePlate in
                    partialResult + (statePlate.found ? 0 : 1)
                }
        }
    }
    
    // MARK: - User Interaction
    public func reset() {
        // Resets the data model
        dataStore.reset()
        allPlates = dataStore.fetch()
        refreshDisplayedPlates()
        updateCounts()
    }
    
    public func tapped(plate: LicensePlateModel) {
        let plateTapped = LicensePlateModel(state: plate.state, plate: plate.plate, found: !plate.found, date: !plate.found ? Date().ISO8601Format() : nil)
        allPlates.removeAll { $0.plate == plate.plate }
        allPlates.append(plateTapped)
        updateCounts()
        refreshDisplayedPlates()
    }
    
    public func saveState() {
        self.dataStore.store(plates: self.allPlates)
    }
}
