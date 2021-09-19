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
    
    // Keeping track of whether the list should be filtered.
    // Don't know who else should be keeping track of this.
    // Eventually, I have to get this initializing from UserDefaults
    @Published var isFiltered: Bool {
        didSet {
            UserDefaults.standard.setValue(isFiltered, forKey: "listIsFiltered")
        }
    }
    
    init() {
        // Get StatePlates from some plist or another
        // On first launch, will be a resource
        // On subsequent launches will be in user's documents directory
        // So need to check there first, and if nothing is there, go get from resource
        isFiltered = UserDefaults.standard.value(forKey: "listIsFiltered") as? Bool ?? false

        // Got the file path, now read it as xml
        statePlates = self.arrayOfStatePlates()
        statePlates.sort { plate1, plate2 in
            plate1.state < plate2.state
        }
        
        // Register to receive notifications
        notificationCenter.addObserver(self, selector: #selector(statePlateUpdated(_ : )), name: .statePlateUpdated, object: nil)
    }
    
    // We need to be told when a statePlate was updated so we know whether to re-filter our array
    @objc func statePlateUpdated(_ notification: Notification) {
        objectWillChange.send()
    }
    
    func reset() {
        // Resets all StatePlates to not found
        statePlates.forEach { statePlate in
            if statePlate.found {
                statePlate.found = false
                statePlate.date = ""
            }
            isFiltered = false
        }
    }
    
    // Now save to disk
    func save() {
        print("Ok, I'm gonna save")
        
        // Let's get the default file manager
        let fileManager = FileManager.default
        
        // Can only save to user's documents directory, so:
        let statesPathURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("states.plist")
        //        print("Path to saved file: \(statesPathURL.absoluteString)")
        
        // And let's try to get some encoded data.
        if let data = encodeStatePlates() {
            print("Data safely encoded")
            print(data)
            do {
                try data.write(to: statesPathURL)
                print("Data safely written to disk. Yay.")
            } catch {
                print("OK, data.write didn't work either")
                print(error.localizedDescription)
            }
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
    
    // Returns a path to either the saved states list in the documents directory or to the one in the main bundle
    // Or if all goes horribly wrong, returns nil.
    private func pathToStates() -> String? {
        // First check for a saved states.plist
        let statesPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("states.plist")
        if !FileManager.default.fileExists(atPath: statesPathURL.absoluteString) {
            print("Nope, not there, so using bundle resource.")
            // Wasn't there, so need to get the one from the main bundle
            if let statesBundlePath = Bundle.main.path(forResource: "states", ofType: "plist") {
                return statesBundlePath
            }
        } else {
            print("Pulling up the saved file from Documents directory.")
            return statesPathURL.absoluteString
        }
        // Something really bizarre happened. We didn't even have our states.plist in our main bundle.
        // So really, we're done here.
        return nil
    }
    
    // Want a function that returns the path to the Documents directory
    func pathToDocuments() -> String? {
        // trying something different
//        let pathToDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        print("Path from search: \(pathToDocuments)")
//        return "\(pathToDocuments)/states.plist"
        
        if let documentsDirectoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let savedFileURL = documentsDirectoryURL.appendingPathComponent("states.plist")
            return savedFileURL.path
        } else {
            return nil
        }
    }
    
    // Want a function that returns the path to the states.plist in the main bundle
    func pathToMainBundle() -> String? {
        Bundle.main.path(forResource: "states", ofType: "plist")
    }
    
    // Parse the xml of the states.plist and return an array of StatePlate structs
    private func arrayOfStatePlates() -> [StatePlate] {
        // First, we'll try to get the data from the saved file
        if let path = pathToDocuments() {
            print("Here's the path: \(path)")
            if let stateXML = FileManager.default.contents(atPath: path) {
                // Hey, there were contents there, so let's try to decode them.
                print("Hey, found a saved data file. Let's read it. ")
                do {
                    return try PropertyListDecoder().decode([StatePlate].self, from: stateXML)
                } catch {
                    print("Error parsing saved states.plist file.")
                    print(error.localizedDescription)
                }
            } else {
                // There was no saved file in Documents, so go to main bundle
                print("Hmm. No saved file, let's try the main bundle.")
                if let pathToMainBundle = pathToMainBundle() {
                    print("OK, got the file from the main bundle.")
                    // We got the path to the resource
                    if let stateXML = FileManager.default.contents(atPath: pathToMainBundle) {
                        // Hey, there were contents there, so let's try to decode them.
                        print("Even better, there were contents in that file! Let's decode them.")
                        do {
                            return try PropertyListDecoder().decode([StatePlate].self, from: stateXML)
                        } catch {
                            print("Error parsing states.plist resource.")
                            print(error.localizedDescription)
                        }
                    }
                    print("No contents in main bundle.")
                }
            }
        }
        // If we got here, there was nothing in the saved file (or an error parsing it.
        // And nothing in the main bundle - which who knows how that happened.
        // So let's just give 'em a plate of nothing.
        let errorState = StatePlate(state: "No state data found", plate: "", found: false, date: "")
        return [errorState]
    }
}

extension Notification.Name {
    static let statePlateUpdated = Notification.Name("statePlateUpdated")
}

