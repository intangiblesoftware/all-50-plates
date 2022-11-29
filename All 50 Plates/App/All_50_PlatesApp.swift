//
//  All_50_PlatesApp.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI
import UIKit

@main
struct All_50_PlatesApp: App {
    @Environment (\.scenePhase) var scenePhase
        
    // Create the statePlate store.
    // Creating it as a mock data store should be done somewhere else I'm sure.
    // But I'm doing it here for now.
    let dataStore: LicensePlateStore = MockDataStore()

    var body: some Scene {
        
        WindowGroup {
            LicensePlateListView(model: LicensePlateListViewModel(with: dataStore))
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // Don't need to do anything here.
                break
            case .background:
                // Don't need to do anything here either.
                break
            case .inactive:
                // However, here, I want to write any changes to the plist
                dataStore.save()
            default:
                print("Wow, some new scenePhase was introduced. Not sure what to do here now...")
            }
        }
    }
}
