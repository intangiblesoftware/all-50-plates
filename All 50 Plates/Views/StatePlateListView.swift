//
//  ContentView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI

struct StatePlateListView: View {
    @ObservedObject var statePlateStore: StatePlateStore
        
    var body: some View {
        NavigationView {
            VStack {
                if statePlateStore.numberRemaining == 0 {
                    VStack {
                        Text("🎉").font(.system(size: 60))
                        Text("You found them all! Congratulations!")
                    }
                } else {
                    List {
                        ForEach(statePlateStore.publishedStatePlates) { statePlate in
                            StatePlateView(statePlate: statePlate)
                        }.listStyle(.plain)
                    }.animation(.default, value: statePlateStore.isFiltered)
                        .onAppear {
                            // Set the default to clear
                        }

                    RemainingPlatesView(numberRemaining: $statePlateStore.numberRemaining)
                }

            }
            .navigationTitle(Text("All 50 Plates"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        statePlateStore.reset()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        statePlateStore.isFiltered.toggle()
                    } label: {
                        if statePlateStore.isFiltered {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        } else {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }
                    }
                }
            }
        }
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static var previews: some View {
        let statePlateStore = StatePlateStore()
        StatePlateListView(statePlateStore: statePlateStore).preferredColorScheme(.light)
        StatePlateListView(statePlateStore: statePlateStore).preferredColorScheme(.dark)
    }
}

