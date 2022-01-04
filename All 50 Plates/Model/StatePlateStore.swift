//
//  StatePlateStore.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/5/21.
//

import Foundation

class StatePlateStore: ObservableObject {
    // The array of all the statePlates
    private var statePlates: [StatePlate] = []
    
    let notificationCenter = NotificationCenter.default


    // Gonna provide a copy of statePlates that's filtered or not
    var publishedStatePlates: [StatePlate] {
        get {
            if isFiltered {
                return statePlates.filter { !$0.found }
            } else {
                return statePlates
            }
        }
    }
        
    @Published var numberRemaining: Int = 51
    
    // Storing filtered state in user defaults so I can restore on launch
    @Published var isFiltered: Bool {
        didSet {
            UserDefaults.standard.setValue(isFiltered, forKey: Key.UserDefaults.listIsFiltered)
        }
    }
    
    init() {
        // Get filtered state from user defaults
        isFiltered = UserDefaults.standard.value(forKey: Key.UserDefaults.listIsFiltered) as? Bool ?? false
        
        // Get StatePlates from some plist or another
        statePlates = self.arrayOfStatePlates()
        
        // And sort them
        statePlates.sort { plate1, plate2 in
            plate1.state < plate2.state
        }
        
        // Now count the found ones
        numberRemaining = countRemaining()
        
        // Register to receive notifications
        notificationCenter.addObserver(self, selector: #selector(statePlateUpdated(_ : )), name: .statePlateUpdated, object: nil)
    }
    
    // We need to be told when a statePlate was updated so we know whether to re-filter our array and to re-count the number remaining
    @objc func statePlateUpdated(_ notification: Notification) {
        numberRemaining = countRemaining()
        objectWillChange.send()
    }
    
    // Resets all StatePlates to not found, clears the dates and turns off the filter and recounts the number remaining. 
    func reset() {
        statePlates.forEach { statePlate in
            if statePlate.found {
                statePlate.found = false
                statePlate.date = ""
            }
            isFiltered = false
        }
        numberRemaining = countRemaining()
    }
    
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
    
    private func countRemaining () -> Int {
        return statePlates.reduce(0) { partialResult, statePlate in
            partialResult + (statePlate.found ? 0 : 1)
        }
    }
    
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
            let data = try encoder.encode(statePlates)
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
        Bundle.main.path(forResource: "states", ofType: "plist")
    }
    
    // Parse the xml of the states.plist and return an array of StatePlate structs
    private func arrayOfStatePlates() -> [StatePlate] {
        // First, we'll try to get the data from the saved file
        if let path = pathToDocuments() {
            if let stateXML = FileManager.default.contents(atPath: path) {
                // Hey, there were contents there, so let's try to decode them.
                do {
                    return try PropertyListDecoder().decode([StatePlate].self, from: stateXML)
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
                            return try PropertyListDecoder().decode([StatePlate].self, from: stateXML)
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
        let errorState = StatePlate(state: "No state data found", plate: "", found: false, date: "")
        return [errorState]
    }
}

extension Notification.Name {
    static let statePlateUpdated = Notification.Name("ISStatePlateUpdated")
}

