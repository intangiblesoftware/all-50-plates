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
                renderColorCells()
                renderFontCells()
                renderHapticsCells()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Developer Tools")
    }
    
    // MARK: - Colors
    
    @ViewBuilder private func renderColorCells() -> some View {
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
    
    // MARK: - Fonts
    
    @ViewBuilder private func renderFontCells() -> some View {
        Section("App Fonts") {
            renderFontCell(Font.appLargeTitle, named: "appLargeTitle", shouldUppercase: true)
            renderFontCell(Font.appTitle, named: "appTitle", shouldUppercase: true)
            renderFontCell(Font.appAction, named: "appTitle", shouldUppercase: true)
            renderFontCell(Font.appText, named: "appText")
            renderFontCell(Font.appControl, named: "appControl")
            renderFontCell(Font.appParagraph, named: "appParagraph")
        }
    }
    
    @ViewBuilder private func renderFontCell(_ font: Font, named name: String, shouldUppercase: Bool = false) -> some View {
        HStack {
            Text(name)
                .fontWeight(.bold)
            Spacer()
            Text("Hello12")
                .font(font)
                .textCase(shouldUppercase ? .uppercase : .none)
        }
    }
    
    // MARK: - Haptics
    
    @ViewBuilder private func renderHapticsCells() -> some View {
        Section("Haptics") {
            renderHapticsCell(.light, named: "Light")
            renderHapticsCell(.strong, named: "Strong")
        }
    }
    
    @ViewBuilder private func renderHapticsCell(_ strength: Haptics.Strength, named name: String) -> some View {
        Button(action: {
            Haptics.playHaptic(strength: strength)
        }) {
            HStack {
                Text(name)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                Spacer()
                Text("(tap for demo)")
                    .foregroundColor(.appText)
            }
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
