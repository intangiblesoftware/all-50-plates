//
//  DeveloperToolsView.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 6/25/23.
//

import SwiftUI

struct DeveloperToolsView: View {
    var body: some View {
        ViewBackground {
            List {
                Text("Developer Tool Goes Here")
                Text("Developer Tool Goes Here")
                Text("Developer Tool Goes Here")
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Developer Tools")
    }
}

struct DeveloperToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DeveloperToolsView()
        }
    }
}
