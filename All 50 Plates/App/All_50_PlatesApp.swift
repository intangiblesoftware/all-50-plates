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
    
    // Create the statePlate store and pass it along to the list view. 
    @StateObject var statePlateStore: StatePlateStore = StatePlateStore()

    var body: some Scene {
        WindowGroup {
            StatePlateListView(statePlateStore: statePlateStore)
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
                statePlateStore.save()
            default:
                print("Wow, some new scenePhase was introduced. Not sure what to do here now...")
            }
        }
    }
}
