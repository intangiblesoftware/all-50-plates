//
//  StatePlate.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import Foundation
import Combine

struct StatePlate: Hashable, Codable, CustomDebugStringConvertible {

    let state: String
    let plate: String
    
    var date: String?
    var found: Bool
    
    // Debug description
    var debugDescription: String {
        return "[State: \(state), Plate: \(plate), Date: \(date ?? "Not set"), Found: \(found)]\n"
    }
        
    enum CodingKeys: String, CodingKey {
        case state
        case plate
        case date
        case found
    }
    
    init(state: String, plate: String, found: Bool, date: String?) {
        self.state = state
        self.plate = plate
        self.date = date
        self.found = found
    }
    
    // Codable initializers
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decode(String.self, forKey: .state)
        plate = try values.decode(String.self, forKey: .plate)
        date = try values.decode(String.self, forKey: .date)
        found = try values.decode(Bool.self, forKey: .found)
    }
    
    // Encodable too
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encode(plate, forKey: .plate)
        try container.encode(date, forKey: .date)
        try container.encode(found, forKey: .found)
    }
    
    // Equatable
    static func == (lhs: StatePlate, rhs: StatePlate) -> Bool {
        lhs.state == rhs.state && lhs.plate == rhs.plate
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
        hasher.combine(plate)
    }
    
    /*
    // Tells this object to toggle its found state
    func toggle() {
        found.toggle()
        if found {
           let dateFound = Date()
           let dateFormatter = DateFormatter()
           dateFormatter.dateStyle = .long
           dateFormatter.timeStyle = .none
           dateFormatter.locale = .current
           date = dateFormatter.string(from: dateFound)
       } else {
           date = ""
       }
    }
     */
}
