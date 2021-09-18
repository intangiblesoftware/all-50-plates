//
//  ContentView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI

struct StatePlateListView: View {
    // I'm not entirely sure why this is a StateObject instead of an ObservedObject.
    // Did this based on randome StackOverflow post I found. 
    @StateObject var statePlateStore: StatePlateStore

    var body: some View {

        NavigationView {
            List {
                ForEach(statePlateStore.publishedStatePlates) { statePlate in
                    StatePlateView(statePlate: statePlate)
                }
            }.animation(.default)
            .navigationTitle(Text("All 50 Plates"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset", action: {
                        statePlateStore.reset()
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        statePlateStore.isFiltered.toggle()
                    }, label: {
                        if statePlateStore.isFiltered {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        } else {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }
                    }).font(.title)
                }
            }
        }
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static var previews: some View {
        StatePlateListView(statePlateStore: StatePlateStore())
    }
}
