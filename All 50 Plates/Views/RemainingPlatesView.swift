//
//  RemainingPlatesView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/23/21.
//

import SwiftUI

struct RemainingPlatesView: ToolbarContent {
    var numberOfPlates: Int
    var numberRemaining: Int
    
    @Binding var platesToView: ListFilterState
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
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
            }
        }
    }
    
    func message() -> String {
        var message = ""
        let numberFound = numberOfPlates - numberRemaining
        
        switch platesToView {
        case .allPlates:
            switch numberRemaining {
            case 0: message = "You found them all! Congratulations!"
            case 1: message = "You have one plate left to find."
            default: message = "You have \(numberRemaining) license plates left to find."
            }

        case .found:
            switch numberRemaining {
            case 0: message = "You found all \(numberOfPlates) plates! Congratulations!"
            case numberOfPlates: message = "You haven't found any so far."
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

/*
 struct RemainingPlatesView_Previews: PreviewProvider {
 static private var numberOfPlates = 51
 static private var allRemaining = 51
 static private var oneRemaining = 1
 static private var someRemaining = 21
 static private var noneRemaining = 0
 static private var allPlates = Binding.constant(ListFilterState.allPlates)
 static private var leftToFind = Binding.constant(ListFilterState.notFound)
 static private var found = Binding.constant(ListFilterState.found)
 
 static var previews: some View {
 VStack {
 Group {
 Text("All Remaining")
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: allRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: allRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: allRemaining, platesToView: found).previewLayout(.sizeThatFits)
 }.previewLayout(.sizeThatFits)
 }
 VStack{
 Group {
 Text("None Remaining")
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: noneRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: noneRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: noneRemaining, platesToView: found).previewLayout(.sizeThatFits)
 }.previewLayout(.sizeThatFits)
 }
 VStack{
 Group {
 Text("One Remaining")
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: oneRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: oneRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: oneRemaining, platesToView: found).previewLayout(.sizeThatFits)
 }.previewLayout(.sizeThatFits)
 }
 VStack {
 Group {
 Text("Some Remaining")
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: someRemaining, platesToView: allPlates).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: someRemaining, platesToView: leftToFind).previewLayout(.sizeThatFits)
 RemainingPlatesView(numberOfPlates: numberOfPlates, numberRemaining: someRemaining, platesToView: found).previewLayout(.sizeThatFits)
 }.previewLayout(.sizeThatFits)
 }.previewLayout(.sizeThatFits)
 }
 }
 */
