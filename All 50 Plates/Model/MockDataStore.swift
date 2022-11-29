//
//  MockDataStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation

class MockDataStore: LicensePlateStore {
    var licensePlates: [LicensePlate] = []
    
    init() {
        licensePlates.append(LicensePlate(state: "South Carolina", plate: "SC", found: true, date: "September 5, 2021"))
        licensePlates.append(LicensePlate(state: "Massachusetts", plate: "MA", found: false, date: "December 31, 2021"))
        licensePlates.append(LicensePlate(state: "Louisianna", plate: "LA", found: true, date:""))
        licensePlates.append(LicensePlate(state: "Washington D.C.", plate: "DC", found: false, date:""))
        licensePlates.append(LicensePlate(state: "Wisconsin", plate: "WI", found: true, date: "2022-01-27"))
        licensePlates.append(LicensePlate(state: "Illinois", plate: "IL", found: false, date: "2022-03-26"))
    }
    
    func save() {
        // The mock does nothing.
    }
    
    func update(plate: LicensePlate) {
        var plateToUpdate = licensePlates.first { $0 == plate }
        plateToUpdate?.found = plate.found
        plateToUpdate?.date = plate.date
    }
}
