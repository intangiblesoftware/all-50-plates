//
//  StatePlate.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import Foundation

class StatePlate: Hashable, Codable, CustomDebugStringConvertible, ObservableObject, Identifiable {
    
    let state: String
    let plate: String
        
    @Published var date: String?
    @Published var found: Bool {
        // observing when the value changes and updating other properties as needed.
        didSet {
            if found {
                date = dateString()
            } else {
                date = ""
            }
        }
    }
    
    // Conform to Identifiable. I want to use state as my ID.
    var id: String {
        get {
            return state
        }
    }
    
    // Debug description
    var debugDescription: String {
        return "[State: \(state), Plate: \(plate), Date: \(date ?? "Not set"), Found: \(found)]\n"
    }
    
    // Needed for encode and decode
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
    required init(from decoder: Decoder) throws {
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
    
    // I'm storing date found as a string formatted the way I want.
    private func dateString() -> String {
        let dateFound = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = .current
        return dateFormatter.string(from: dateFound)
    }
}
