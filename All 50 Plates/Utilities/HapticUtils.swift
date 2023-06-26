//
//  HapticUtils.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 6/25/23.
//

import Foundation
import AVFoundation

struct Haptics {

    enum Strength {
        case light
        case strong
    }
    
    static func playHaptic(strength: Haptics.Strength) {
        switch strength {
        case .light:
            playLightHaptic()
        case .strong:
            playStrongHaptic()
        }
    }
    
    private static func playLightHaptic() {
        AudioServicesPlaySystemSound(1519)
    }
    
    private static func playStrongHaptic() {
        AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
    }
    
}
