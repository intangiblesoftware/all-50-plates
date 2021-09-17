//
//  ContentView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI
import Combine

struct StatePlateListView: View {
    @ObservedObject var statePlateStore: StatePlateStore
    
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
                    Button("Reset", action: {})
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        statePlateStore.toggleFilter()
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
