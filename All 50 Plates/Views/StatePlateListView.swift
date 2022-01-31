//
//  ContentView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI

struct StatePlateListView: View {
    @ObservedObject var statePlateStore: StatePlateStore
    @State private var resetAlertIsShowing: Bool = false
    
    var body: some View {
        NavigationView {
            VStack() {
                List {
                    ForEach(statePlateStore.publishedStatePlates) { statePlate in
                        StatePlateView(statePlate: statePlate)
                    }.listStyle(.plain)
                }
                .alert("You won!", isPresented: $statePlateStore.gameWon, actions: {
                    Button("OK", role: .cancel) {}
                }, message: {
                    Text("You found all 51 license plates!\nCongratulations! ")
                })
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
                        resetAlertIsShowing = true
                    }
                    .foregroundColor(Color("ButtonColor"))
                    .alert(isPresented: $resetAlertIsShowing) {
                        let resetButton = Alert.Button.destructive(Text("Reset")) {
                            statePlateStore.reset()
                        }
                        let cancelButton = Alert.Button.cancel()
                        return Alert(title: Text("Reset the game?"), message: Text("Reset everything back to the start?"), primaryButton: resetButton, secondaryButton: cancelButton)
                    }
                }
            }.background(Color("AppBackground"))
        }.onAppear {
            // Variety of ways to control appearance of nav bar views.
            // I chose this one since I only have one nav bar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "AppBackground")
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "MainText") ?? UIColor.black]
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "MainText") ?? UIColor.black]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatePlateListView(statePlateStore: StatePlateStore()).preferredColorScheme(.light)
            StatePlateListView(statePlateStore: StatePlateStore()).preferredColorScheme(.dark)
        }
    }
}

