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
            VStack(spacing: 0) {
                // trying to make the app background color behind nav bar be the same.
                // found this solution - put a 0 sized rectangle right at the top touching the nav bar area,
                // and color that rectangle the color you want. Seems glitchy in simulator.
                Rectangle()
                    .frame(height: 0)
                    .background(Color("AppBackground"))
                List {
                    ForEach(statePlateStore.publishedStatePlates) { statePlate in
                        StatePlateView(statePlate: statePlate)
                    }.listStyle(.plain)
                }
                .animation(.default, value: statePlateStore.listState)
                .onAppear {
                    UITableView.appearance().backgroundColor = UIColor.clear
                }
                RemainingPlatesView(numberRemaining: $statePlateStore.numberRemaining, platesToView: $statePlateStore.listState)
            }
            .navigationTitle(Text("All 50 Plates"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        statePlateStore.reset()
                    }
                }
            }.background(Color("AppBackground"))
        }.background(Color("AppBackground"))
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static var previews: some View {
        let statePlateStore = StatePlateStore()
        Group {
            StatePlateListView(statePlateStore: statePlateStore).preferredColorScheme(.light)
            StatePlateListView(statePlateStore: statePlateStore).preferredColorScheme(.dark)
        }
    }
}

