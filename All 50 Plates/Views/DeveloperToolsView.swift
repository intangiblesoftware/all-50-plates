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
            renderColorCells()
        }
        .navigationTitle("Developer Tools")
    }
    
    @ViewBuilder private func renderColorCells() -> some View {
        List {
            Section("App Colors") {
                renderColorCell(Color.accentColor, named: "accentColor")
                renderColorCell(Color.appDark, named: "appDark")
                renderColorCell(Color.appLight, named: "appLight")
                renderColorCell(Color.appBackground, named: "appBackground")
                renderColorCell(Color.appCardBackground, named: "appCardBackground")
                renderColorCell(Color.appText, named: "appText")
                renderColorCell(Color.appSubtext, named: "appSubtext")
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder private func renderColorCell(_ color: Color, named name: String) -> some View {
        let cornerRadius: CGFloat = 8
        
        HStack {
            Text(name)
                .fontWeight(.bold)
            Spacer()
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}

struct DeveloperToolsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                DeveloperToolsView()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationStack {
                DeveloperToolsView()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
