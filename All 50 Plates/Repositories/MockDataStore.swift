//
//  MockDataStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation

class MockDataStore: LicensePlateStoreProtocol {
    // Creating some mock data that doesn't always conform to the way the data should be stored.
    // Doing this to make sure I handle possible odd states and the old way I used to store dates. 
    func fetch() -> [LicensePlateModel] {
        [
            LicensePlateModel(state: "South Carolina", plate: "SC", found: false, date: "September 5, 2021"),
            LicensePlateModel(state: "Massachusetts", plate: "MA", found: true, date: "December 31, 2021"),
            LicensePlateModel(state: "Louisianna", plate: "LA", found: false, date:""),
            LicensePlateModel(state: "Washington D.C.", plate: "DC", found: true, date:""),
            LicensePlateModel(state: "Wisconsin", plate: "WI", found: false, date: "2022-01-27T07:00:00Z"),
            LicensePlateModel(state: "Illinois", plate: "IL", found: true, date: "2022-03-26T07:00:00Z")
        ]
    }
    
    func store(plates: [LicensePlateModel]) {
        // The mock store doesn't save anything
    }
    
    func reset() { }
}
