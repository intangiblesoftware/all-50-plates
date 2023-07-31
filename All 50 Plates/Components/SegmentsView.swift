//
//  SegmentsView.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 7/23/23.
//

import SwiftUI

struct SegmentsView: View {
    @Binding var selectedIndex: Int
    
    private let options: [String]
    private let cornerRadius: CGFloat
    private let backgroundColor: Color
    private let selectedBackgroundColor: Color
    private let textColor: Color
    private let selectedTextColor: Color
    private let font: Font
    private let animationDuration: Double = 0.2
    
    init(_ options: [String],
         selectedIndex: Binding<Int>,
         cornerRadius: CGFloat = 8,
         backgroundColor: Color = Color.black,
         selectedBackgroundColor: Color = Color.pink,
         textColor: Color = Color.gray,
         selectedTextColor: Color = Color.white,
         font: Font = Font.headline) {
        self.options = options
        self._selectedIndex = selectedIndex
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.font = font
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // selected tab
                let segmentStartPoint = geometry.size.width / CGFloat(options.count) * CGFloat(selectedIndex) + geometry.size.width / CGFloat(options.count) / 2
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(selectedBackgroundColor)
                    .frame(width: (geometry.size.width / CGFloat(options.count)), height: geometry.size.height)
                    .position(x: segmentStartPoint, y: geometry.frame(in: .local).midY)
                    .animation(.spring(response: animationDuration), value: selectedIndex)
                
                // options
                HStack(spacing: 0) {
                    ForEach(options, id: \.self) { curOption in
                        Text(curOption)
                            .foregroundColor(options.firstIndex(of: curOption) == selectedIndex ? selectedTextColor : textColor)
                            .font(font)
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width / CGFloat(options.count))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: animationDuration)) {
                                    selectedIndex = options.firstIndex(of: curOption) ?? 0
                                }
                            }
                    }
                }
            }
            .frame(height: geometry.size.height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
        }
    }
}

struct SegmentsView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentsView([ListFilterState.allPlates.displayText,
                      ListFilterState.notFound.displayText,
                      ListFilterState.found.displayText],
                     selectedIndex: .constant(0))
            .frame(height: 38)
            .padding()
    }
}
