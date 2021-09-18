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
        
    // Conform to Identifiable. I want to use state as my ID. 
    var id: String {
        get {
            return state
        }
    }
    
    @Published var date: String?
    @Published var found: Bool {
        // observing when the value changes and updating other properties as needed.
        didSet {
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
    }
    
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
}
