//
//  RemainingPlatesView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/23/21.
//

import SwiftUI

struct RemainingPlatesView: View {
    @Binding var numberRemaining: Int
    
    var body: some View {
        Text(message(for:numberRemaining))
            .transition(AnyTransition.opacity.animation(.easeInOut))
    }
    
    func message(for numberRemaining: Int) -> String {
        var message = ""
        switch numberRemaining {
        case 0: message = ""
        case 1: message = "You have one plate left to find."
        default: message = "You have \(numberRemaining) license plates left to find."
        }
        return message
    }
}

struct RemainingPlatesView_Previews: PreviewProvider {
    static private var allRemaining = Binding.constant(51)
    static private var noneRemaining = Binding.constant(0)
    static private var oneRemaining = Binding.constant(1)
    static private var someRemaining = Binding.constant(21)
    
    static var previews: some View {
        VStack {
            RemainingPlatesView(numberRemaining: allRemaining)
            RemainingPlatesView(numberRemaining: noneRemaining)
            RemainingPlatesView(numberRemaining: oneRemaining)
            RemainingPlatesView(numberRemaining: someRemaining)
        }
    }
}
