//
//  RemainingPlatesView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/23/21.
//

import SwiftUI

struct RemainingPlatesView: View {
    @Binding var numberRemaining: Int
    @Binding var platesToView: ListFilterState
    
    var body: some View {
        VStack {
            Picker("Plates", selection: $platesToView) {
                Text("All Plates").tag(ListFilterState.allPlates)
                Text("Left to Find").tag(ListFilterState.notFound)
                Text("Found").tag(ListFilterState.found)
            }.pickerStyle(SegmentedPickerStyle())
                .padding()
                .foregroundColor(Color("MainText"))
            Text(message())
                .foregroundColor(Color("MainText"))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .transition(AnyTransition.opacity.animation(.easeInOut))
        }.background(Color("AppBackground"))
    }
    
    func message() -> String {
        var message = ""
        let numberFound = 51 - numberRemaining
        switch platesToView {
        case .allPlates:
            switch numberRemaining {
            case 0: message = "You found them all! Congratulations!"
            case 1: message = "You have one plate left to find."
            default: message = "You have \(numberRemaining) license plates left to find."
            }

        case .found:
            switch numberRemaining {
            case 0: message = "You found all 51 plates! Congratulations!"
            case 51: message = "You haven't found any so far."
            default: message = "You found \(numberFound) so far."
            }

        case .notFound:
            switch numberRemaining {
            case 0: message = "You found them all! Congratulations!"
            case 1: message = "You have one plate left to find."
            default: message = "You have \(numberRemaining) license plates left to find."
            }
        }
        return message
    }
}

struct RemainingPlatesView_Previews: PreviewProvider {
    static private var allRemaining = Binding.constant(51)
    static private var noneRemaining = Binding.constant(0)
    static private var oneRemaining = Binding.constant(1)
    static private var someRemaining = Binding.constant(21)
    static private var allPlates = Binding.constant(ListFilterState.allPlates)
    static private var leftToFind = Binding.constant(ListFilterState.notFound)
    static private var found = Binding.constant(ListFilterState.found)
    
    static var previews: some View {
        VStack {
            Group {
                Text("All plates to Find")
                RemainingPlatesView(numberRemaining: allRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: allRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: allRemaining, platesToView: found).previewLayout(.sizeThatFits)
            }.previewLayout(.sizeThatFits)
            Group {
                Text("None remaining")
                RemainingPlatesView(numberRemaining: noneRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: noneRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: noneRemaining, platesToView: found).previewLayout(.sizeThatFits)
            }.previewLayout(.sizeThatFits)
            Group {
                Text("One Remaining")
                RemainingPlatesView(numberRemaining: oneRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: oneRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: oneRemaining, platesToView: found).previewLayout(.sizeThatFits)
            }.previewLayout(.sizeThatFits)
            Group {
                Text("Some remaining")
                RemainingPlatesView(numberRemaining: someRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: someRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
                RemainingPlatesView(numberRemaining: someRemaining, platesToView: found).previewLayout(.sizeThatFits)
            }.previewLayout(.sizeThatFits)
        }.previewLayout(.sizeThatFits)
    }
}
