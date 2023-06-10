//
//  StatePlateStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import Foundation

protocol LicensePlateStoreProtocol {
    func fetch() -> [LicensePlateModel]
    func store(plates: [LicensePlateModel]) -> Void
    func reset() -> Void
}

/// A dumb data store that has 2 functions:
/// Read and returns the saved plates data from disk.
/// Save a given array of LicensePlate structs to disk.
class DataStore: LicensePlateStoreProtocol {
    // MARK: - Conform to LicensePlateStoreProtocol

    func store(plates: [LicensePlateModel]) {
        if let documentDirectoryURL = documentDirectoryURL() {
            // We got the document directory
            // Encode and write the data.
            let statesPlistURL = documentDirectoryURL.appendingPathComponent(Key.ResourceName.statesPlist)
            if let data = encode(plates) {
                write(data: data, to: statesPlistURL)
            } else {
                print("Failed to encode the state.plist")
            }
        }
    }
    
    func fetch() -> [LicensePlateModel] {
        // First, we'll try to get the data from the saved file
        if let path = pathToSavedStatesFile() {
            if let savedStates = FileManager.default.contents(atPath: path) {
                // Hey, there were contents there, so let's try to decode them.
                do {
                    return try PropertyListDecoder().decode([LicensePlateModel].self, from: savedStates)
                } catch {
                    print("Error parsing saved states.plist file.")
                    print(error.localizedDescription)
                }
            } else {
                // There was no saved file in Documents, so go to main bundle
                if let pathToDefaultStates = pathToDefaultDataFile() {
                    // We got the path to the resource
                    if let defaultStates = FileManager.default.contents(atPath: pathToDefaultStates) {
                        // Hey, there were contents there, so let's try to decode them.
                        do {
                            return try PropertyListDecoder().decode([LicensePlateModel].self, from: defaultStates)
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
        let errorState = LicensePlateModel(state: "No license plate data found.", plate: "", found: false, date: "")
        return [errorState]
    }
    
    func reset() {
        if let path = pathToSavedStatesFile() {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Error deleting saved states file.")
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - Private functionality
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
    
    private func encode (_ plates: [LicensePlateModel]) -> Data? {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(plates)
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
    func pathToSavedStatesFile() -> String? {
        if let documentsDirectoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let savedFileURL = documentsDirectoryURL.appendingPathComponent(Key.ResourceName.statesPlist)
            return savedFileURL.path
        } else {
            print("Couldn't find the document directory. Not entirely sure how that could have happened. ")
            return nil
        }
    }
    
    // Returns the path to the states.plist in the main bundle
    func pathToDefaultDataFile() -> String? {
        Bundle.main.path(forResource: "plates", ofType: "plist")
    }    
}
