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
    
    // Gonna provide a copy of statePlates that's filtered or not
    var publishedStatePlates: [StatePlate] {
        get {
            if isFiltered {
                return statePlates.filter { statePlate in
                    !statePlate.found
                }
            } else {
                return statePlates
            }
        }
    }
    
    // Keeping track of whether the list should be filtered.
    // Don't know who else should be keeping track of this.
    // Eventually, I have to get this initializing from UserDefaults
    @Published var isFiltered: Bool = false
            
    init() {
        // Get StatePlates from some plist or another
        // On first launch, will be a resource
        // On subsequent launches will be in user's documents directory
        // So need to check there first, and if nothing is there, go get from resource
        
        if let pathToStates = self.pathToStates() {
            // Got the file path, now read it as xml
            statePlates = self.arrayOfStatePlates(from: pathToStates)
            statePlates.sort { plate1, plate2 in
                plate1.state < plate2.state
            }
        } else {
            print("Path to states.plist didn't exist anywhere.")
        }
    }
    
//    func statePlateUpdated() {
//        objectWillChange.send()
//    }
//    
    // Returns a path to either the saved states list in the documents directory or to the one in the main bundle
    // Or if all goes horribly wrong, returns nil.
    private func pathToStates() -> String? {
        // First check for a saved states.plist
        let statesPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("states.plist")
        if !FileManager.default.fileExists(atPath: statesPathURL.absoluteString) {
            // Wasn't there, so need to get the one from the main bundle
            if let statesBundlePath = Bundle.main.path(forResource: "states", ofType: "plist") {
                return statesBundlePath
            }
        } else {
            return statesPathURL.absoluteString
        }
        // Something really bizarre happened. We didn't even have our states.plist in our main bundle.
        // So really, we're done here.
        return nil
    }
    
    // Parse the xml of the states.plist and return an array of StatePlate structs
    private func arrayOfStatePlates(from path: String) -> [StatePlate] {
        if let stateXML = FileManager.default.contents(atPath: path) {
            do {
                return try PropertyListDecoder().decode([StatePlate].self, from: stateXML)
            } catch {
                print("Error parsing states.plist file.")
                print(error)
            }
        }
        let errorState = StatePlate(state: "No state data found", plate: "", found: false, date: "")
        return [errorState]
    }
}
