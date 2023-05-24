//
//  LicensePlateViewModel.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 3/21/22.
//

import Foundation
import SwiftUI

class LicensePlateViewModel: ObservableObject, Identifiable {    
    let stateName: String
    let imageName: String
    
    @Published var found: Bool {
        didSet {
            if found {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                self.dateFound = dateFormatter.string(from: Date())
            } else {
                self.dateFound = nil
            }
        }
    }
    
    @Published var dateFound: String?
    
    var id: String {
        // Since image name is the 2-letter postal abbreviation, we can use that as an ID
        imageName
    }
    
    var model: LicensePlateModel {
        LicensePlateModel(state: stateName, plate: imageName, found: found, date: dateFound)
    }
        
    init(licensePlate: LicensePlateModel) {
        self.stateName = licensePlate.state
        self.imageName = licensePlate.plate
        self.dateFound = licensePlate.date
        self.found = licensePlate.found

        // This is gonna be a bit weird.
        // I have to store dates as string, and I want to store in ISO8601 format.
        // But when I first created this, I didn't do that. I used my own dumb format.
        // So now, I have to read in the date string from the plate and figure out
        // which format it's in so I can convert it to an actual Date object.
        // Then, I need to use that date object to re-create a string that's
        // properly formatted for the user's current locale, cause I want to be
        // supportive of that sort of thing.
        // So to sum up, string -> date -> string. Sounds dumb to me, but I think
        // I have to do it this way cause I don't know how to store an optional date
        // property but leave it as nil if the plate is not found yet. :shrug:
        let oldDateFormatter = DateFormatter()
        oldDateFormatter.dateFormat = "MMMM d, yyyy"
        
        if let plateDate = licensePlate.date {
            var dateFound = oldDateFormatter.date(from: plateDate)
            
            if dateFound == nil {
                // Old style failed, so let's try ISO8601 formatting instead
                let isoDateFormatter = ISO8601DateFormatter()
                isoDateFormatter.formatOptions = .withFullDate
                dateFound = isoDateFormatter.date(from: plateDate)
            }
            
            // So now, we have a dateFound (or not)
            if let dateFound = dateFound {
                // Now a new, locale-aware date formatter.
                let newDateFormatter = DateFormatter()
                newDateFormatter.dateStyle = .long
                newDateFormatter.timeStyle = .none
                self.dateFound = newDateFormatter.string(from: dateFound)
            }
        }
    }    
}
