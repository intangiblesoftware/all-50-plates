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
        ViewBackground(color: .appBackground) {
            VStack(spacing: 0) {
                AppHeaderView().frame(maxWidth: .infinity, maxHeight: 72.0)
                GameProgressView().frame(maxWidth: .infinity, maxHeight: 72.0)
                if model.displayedPlates.count == 0 {
                    EmptyListView(filterState: model.filterState).frame(maxHeight: .infinity)
                } else {
                    List (model.displayedPlates) { licensePlateModel in
                        Button {
                            impact.impactOccurred()
                            withAnimation {
                                model.tapped(plate: licensePlateModel)
                            }
                        } label: {
                            LicensePlateView(plateModel: licensePlateModel)
                                .listRowSeparator(.hidden)
                        }.buttonStyle(MyButtonStyle())
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appBackground)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
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
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct EmptyListView: View {
    let filterState: ListFilterState
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: filterState.emptyImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.appSubtext)
                    .padding(.bottom, 16)
                Text(filterState.emptyTitle)
                    .foregroundColor(.appSubtext)
                    .font(.appWarningTitle)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 3)
                Text(filterState.emptyMessage)
                    .foregroundColor(.appSubtext)
                    .font(.appWarningMessage)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
        }
    }
}

struct StatePlateListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LicensePlateListView()
                .environmentObject(AppModel(dataStore: MockDataStore()))
                .previewDisplayName("List View")
            EmptyListView(filterState: .found)
                .previewDisplayName("Empty Found View")
            EmptyListView(filterState: .notFound)
                .previewDisplayName("Empty Not Found View")
        }
    }
}


