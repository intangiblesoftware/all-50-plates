//
//  StatePlate.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import Foundation

/// A Struct representing a single state's license plate, whether it's been found and the date found, if any.
struct LicensePlate: CustomDebugStringConvertible, Codable {
    
    // MARK: - Properties
    let state: String
    let plate: String
    let date: String?
    let found: Bool
    
    // Debug description
    var debugDescription: String {
        return "[State: \(state), Plate: \(plate), Date: \(date ?? "Not set"), Found: \(found)]\n"
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case state
        case plate
        case date
        case found
    }
    
    /// Inits a license plate from a decoder
    /// - Parameter decoder: The decoder
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decode(String.self, forKey: .state)
        plate = try values.decode(String.self, forKey: .plate)
        date = try values.decode(String.self, forKey: .date)
        found = try values.decode(Bool.self, forKey: .found)
    }
    
    /// Encodes a license plate to save to disk
    /// - Parameter encoder: The encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encode(plate, forKey: .plate)
        try container.encode(date, forKey: .date)
        try container.encode(found, forKey: .found)
    }
    
    // MARK: - Lifecycle
    /// Init a license plate with its properties
    /// - Parameters:
    ///   - state: The full name of the state. Also used as the id of the struct.
    ///   - plate: The state's 2 letter postal abbreviation. Also used as the name of the license plate image. 
    ///   - found: Boolean indicating whether this plate has been found yet.
    ///   - date: The date the plate was found.
    init(state: String, plate: String, found: Bool, date: String?) {
        self.state = state
        self.plate = plate
        self.date = date
        self.found = found
    }
}
