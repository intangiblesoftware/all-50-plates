//
//  StatePlateStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import Foundation

// DataStore is now a "dumb" store whose only function is to
// get the license plate data stored on disk
// and then save to disk on command.
// It knows nothing about anything else in the app.
// Conforms to a protocol so it can be swapped out with a mock data store for testing purposes.

class DataStore: LicensePlateStore {
    // The array of all the statePlates
    internal var licensePlates: [LicensePlate] = []
    
    let notificationCenter = NotificationCenter.default

    // Gonna provide a copy of statePlates that's filtered or not
    var publishedStatePlates: [LicensePlate] {
        get {
                return licensePlates
        }
    }
        
    var numberRemaining: Int = 51
    
    var gameWon: Bool = false
    
    init() {
        
        // Get license plates from some plist or another
        licensePlates = self.arrayOfStatePlates()
        
        // And sort them
        licensePlates.sort { plate1, plate2 in
            plate1.state < plate2.state
        }
        
//        // Now count the unfound ones
//        numberRemaining = countRemaining()
//
//        gameWon = numberRemaining <= 0
        
        // Register to receive notifications
        // notificationCenter.addObserver(self, selector: #selector(statePlateUpdated(_ : )), name: .statePlateUpdated, object: nil)
    }
    
    // We need to be told when a statePlate was updated so we know whether to re-filter our array and to re-count the number remaining
    func update(plate: LicensePlate) {
        var plateToUpdate = licensePlates.first { $0 == plate }
        plateToUpdate?.found = plate.found
        plateToUpdate?.date = plate.date
    }
    
    // Resets all StatePlates to not found, clears the dates and turns off the filter and recounts the number remaining. 
//    func reset() {
//        licensePlates.forEach { plate in
//            if plate.found {
//                plate.found = false
//                plate.date = ""
//            }
//            listState = .allPlates
//        }
//        numberRemaining = countRemaining()
//        gameWon = false
//    }
//    
    // Now save to disk
    func save() {
        if let documentDirectoryURL = documentDirectoryURL() {
            // We got the document directory
            // Encode and write the data.
            let statesPlistURL = documentDirectoryURL.appendingPathComponent(Key.ResourceName.statesPlist)
            if let data = encodeStatePlates() {
                write(data: data, to: statesPlistURL)
            } else {
                print("Failed to encode the state.plist")
            }
        }
    }
    
//    private func countRemaining () -> Int {
//        return licensePlates.reduce(0) { partialResult, statePlate in
//            partialResult + (statePlate.found ? 0 : 1)
//        }
//    }
    
    private func documentDirectoryURL () -> URL? {
        // Let's get the default file manager
        let fileManager = FileManager.default
        
        do {
            return try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("Could not get the Document directory. That's weird.")
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func encodeStatePlates () -> Data? {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(licensePlates)
            return data
        } catch {
            print("Error encoding the data.")
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func write(data: Data, to url: URL) {
        do {
            try data.write(to: url)
        } catch {
            print("Unable to write data to \(url)")
            print(error.localizedDescription)
        }
    }
        
    // Returns the path to the states.plist in the app's document directory
    func pathToDocuments() -> String? {
        if let documentsDirectoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let savedFileURL = documentsDirectoryURL.appendingPathComponent(Key.ResourceName.statesPlist)
            return savedFileURL.path
        } else {
            print("Couldn't find the document directory. Not entirely sure how that could have happened. ")
            return nil
        }
    }
    
    // Returns the path to the states.plist in the main bundle
    func pathToMainBundle() -> String? {
        Bundle.main.path(forResource: "plates", ofType: "plist")
    }
    
    // Parse the xml of the states.plist and return an array of StatePlate structs
    private func arrayOfStatePlates() -> [LicensePlate] {
        // First, we'll try to get the data from the saved file
        if let path = pathToDocuments() {
            if let stateXML = FileManager.default.contents(atPath: path) {
                // Hey, there were contents there, so let's try to decode them.
                do {
                    return try PropertyListDecoder().decode([LicensePlate].self, from: stateXML)
                } catch {
                    print("Error parsing saved states.plist file.")
                    print(error.localizedDescription)
                }
            } else {
                // There was no saved file in Documents, so go to main bundle
                if let pathToMainBundle = pathToMainBundle() {
                    // We got the path to the resource
                    if let stateXML = FileManager.default.contents(atPath: pathToMainBundle) {
                        // Hey, there were contents there, so let's try to decode them.
                        do {
                            return try PropertyListDecoder().decode([LicensePlate].self, from: stateXML)
                        } catch {
                            print("Error parsing states.plist resource.")
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            print("No file in either the document directory or the main bundle.")
            print("This is a serious, and interesting problem to have.")
        }
        // If we got here, there was nothing in the saved file (or an error parsing it.
        // And nothing in the main bundle - which who knows how that happened.
        // So let's just give 'em a heaping plate of nothing.
        let errorState = LicensePlate(state: "No state data found", plate: "", found: false, date: "")
        return [errorState]
    }
}

extension Notification.Name {
    static let statePlateUpdated = Notification.Name("ISLicensePlateUpdated")
}

