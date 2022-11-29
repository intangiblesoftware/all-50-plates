//
//  LicensePlateStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation

protocol LicensePlateStore {
    var licensePlates: [LicensePlate] { get }
    func save() -> Void
    func update(plate: LicensePlate) -> Void
}
