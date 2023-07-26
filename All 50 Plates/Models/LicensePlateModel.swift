//
//  LicensePlateModel.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import Foundation

/// A Struct representing a single state's license plate, whether it's been found and the date found, if any.
struct LicensePlateModel: CustomDebugStringConvertible, Codable, Identifiable {
    
    // MARK: - Properties
    let state: String 
    let plate: String
    var date: String?
    var found: Bool
    
    // Debug description
    var debugDescription: String {
        return "[State: \(state), Plate: \(plate), Date: \(date ?? "Not set"), Found: \(found)]\n"
    }
    
    // Identifiable conformance
    var id: String {
        // Since image name is the 2-letter postal abbreviation, we can use that as an ID
        plate
    }
    
    var dateDisplay: String {
        guard let dateFound = date,
              let isoDate = ISO8601DateFormatter().date(from: dateFound) else
        {
            return ""
        }
        return isoDate.formatted(date: .long, time: .omitted)
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
        found = try values.decode(Bool.self, forKey: .found)
        date = try values.decode(String.self, forKey: .date)
        
        self.updateDateFormat()
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
    
    private mutating func updateDateFormat() {
        // This is gonna be a bit weird.
        // I have to store dates as string, and I want to store in ISO8601 format.
        // But when I first created this, I didn't do that. I used my own dumb format.
        // So now, I have to read in the date string from the plate and figure out
        // which format it's in so I can convert it to an actual Date object.
        // Then, I need to use that date object to re-create a string that's
        // properly formatted for the user's current locale, cause I want to be
        // supportive of that sort of thing.
        let oldDateFormatter = DateFormatter()
        oldDateFormatter.dateFormat = "MMMM d, yyyy"
        
        if let plateDateString = date {
            var dateFound = oldDateFormatter.date(from: plateDateString)
            
            if dateFound == nil {
                // Old style failed, so let's try ISO8601 formatting instead
                let isoDateFormatter = ISO8601DateFormatter()
                //isoDateFormatter.formatOptions = .withFullDate
                dateFound = isoDateFormatter.date(from: plateDateString)
            }
            
            // So now, we have a dateFound (or not)
            if let dateFound = dateFound {
                let newDateFormatter = ISO8601DateFormatter()
                date = newDateFormatter.string(from: dateFound)
            }
        }
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
        self.updateDateFormat()
    }    
}
