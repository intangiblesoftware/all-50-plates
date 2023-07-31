//
//  VScrollView.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 6/25/23.
//

import SwiftUI

/// A convenience view that combines a VStack and a ScrollView.
struct VScrollView<Content: View>: View {
    var content: () -> Content
    var alignment: HorizontalAlignment
    var spacing: CGFloat?
    
    init(alignment: HorizontalAlignment = .center,
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: alignment, spacing: spacing) {
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct VScrollView_Previews: PreviewProvider {
    static var texts: [String] {
        var result = [String]()

        for i in 1 ..< 101 {
            result.append("Item \(i)")
        }
        
        return result
    }
    
    static private var allPlates = Binding.constant(ListFilterState.allPlates)

    static var previews: some View {
        VStack {
            VScrollView(spacing: 20) {
                ForEach(texts, id: \.self) { text in
                    Text(text)
                        .font(.body)
                }
            }
            FilterSelectorView().environmentObject(AppModel(dataStore: MockDataStore()))
                .frame(maxWidth: .infinity, maxHeight: 72.0)
        }
    }
}
