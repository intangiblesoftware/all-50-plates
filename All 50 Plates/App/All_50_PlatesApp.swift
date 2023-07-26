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
    
    @StateObject var appModel = AppModel(dataStore: DataStore())
    
    var body: some Scene {
        
        WindowGroup {
            LicensePlateListView().environmentObject(appModel)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
                case .active:
                    // Don't need to do anything here.
                    break
                case .background, .inactive:
                    // Let the app model know we're moving to the backgroud
                    appModel.saveState()
                    break
                default:
                    appModel.saveState()
            }
        }
    }
}
