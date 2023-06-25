//
//  LicensePlateListView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI

struct LicensePlateListView: View {
    // Watches the model for changes to the list
    @ObservedObject var model: AppModel
    
    // A purely local state variable to track whether the reset alert is showing.
    @State private var settingsSheetIsShowing: Bool = false
    
    init(model: AppModel) {
        self.model = model
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "MainText") ?? .label]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "MainText") ?? .label]        
    }
    
    var body: some View {
        NavigationStack {
            List (model.displayedPlates) { licensePlateModel in
                LicensePlateView(plateModel: licensePlateModel, appModel: model)
                    .listRowSeparator(.hidden)
            }.listStyle(.plain)
                .navigationTitle(Text("All 50 Plates"))
                .toolbar {
                    Button {
                        settingsSheetIsShowing = true;
                    } label: {
                        Image(systemName: "gear").foregroundColor(Color("ButtonColor")).imageScale(.large).fontWeight(.bold)
                    }
                    
                }
                .overlay(Group {
                    if model.displayedPlates.isEmpty {
                        EmptyListView(filterState: model.filterState)
                    }
                })
                .sheet(isPresented: $settingsSheetIsShowing) {
                    SettingsView(model: model, isShowing: $settingsSheetIsShowing)
                }
            RemainingPlatesView(numberOfPlates: model.totalPlates,
                                numberRemaining: model.numberRemaining,
                                platesToView: $model.filterState)
            .padding(.bottom, 24.0)
        }
    }
}

struct EmptyListView: View {
    let filterState: ListFilterState
    var body: some View {
        ZStack {
            switch filterState {
                case .allPlates:
                    // TODO: Need a better message - this would happen if there were no data
                    Text("Uh, oh. Something went really wrong.")
                case .found:
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .padding(16)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color("AccentColor"), Color("ButtonColor"))
                case .notFound:
                    Image(systemName: "party.popper.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color("AccentColor"), Color("ButtonColor"))
                        .padding()
            }
        }
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static let appModel: AppModel = AppModel(dataStore: MockDataStore())
    static var previews: some View {
        Group {
            LicensePlateListView(model: appModel).preferredColorScheme(.light)
            LicensePlateListView(model: appModel).preferredColorScheme(.dark)
        }
    }
}


