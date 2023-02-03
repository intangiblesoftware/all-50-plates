//
//  MockDataStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation

class MockDataStore: LicensePlateStoreProtocol {
    func fetch() -> [LicensePlate] {
        [
            LicensePlate(state: "South Carolina", plate: "SC", found: true, date: "September 5, 2021"),
            LicensePlate(state: "Massachusetts", plate: "MA", found: false, date: "December 31, 2021"),
            LicensePlate(state: "Louisianna", plate: "LA", found: true, date:""),
            LicensePlate(state: "Washington D.C.", plate: "DC", found: false, date:""),
            LicensePlate(state: "Wisconsin", plate: "WI", found: true, date: "2022-01-27"),
            LicensePlate(state: "Illinois", plate: "IL", found: false, date: "2022-03-26")
        ]
    }
    
    func store(plates: [LicensePlate]) {
        // The mock store doesn't save anything
    }
}
