//
//  LicensePlateListView.swift
//  All 50 Plates
//
//  Created by Jim Dabrowski on 9/4/21.
//

import SwiftUI

struct LicensePlateListView: View {
    // Watches the model for changes to the list
    @EnvironmentObject var model: AppModel
    
    private var impact = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ViewBackground(color: .red) {
            VStack(spacing: 0) {
                AppHeaderView().frame(maxWidth: .infinity, maxHeight: 72.0)
                GameProgressView().frame(maxWidth: .infinity, maxHeight: 72.0)
                List (model.displayedPlates) { licensePlateModel in
                    Button {
                        impact.impactOccurred()
                        withAnimation {
                            model.tapped(plate: licensePlateModel)
                        }
                    } label: {
                        LicensePlateView(plateModel: licensePlateModel)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appBackground)
                    }.buttonStyle(MyButtonStyle()).listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                FilterSelectorView()
                    .frame(maxWidth: .infinity, maxHeight: 72.0)
            }
            .sheet(isPresented: $model.aboutIsShowing) {
                AboutView()
            }
        }
    }
}

struct MyButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        if(configuration.isPressed)
        {
        }
        else
        {
        }
        
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
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
                        .foregroundStyle(Color("AccentColor"))
                case .notFound:
                    Image(systemName: "party.popper.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color("AccentColor"))
                        .padding()
            }
        }
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlateListView()
            .environmentObject(AppModel(dataStore: MockDataStore()))
    }
}


