//
//  ViewBackground.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 6/25/23.
//

import SwiftUI

/// Place any view inside ViewBackground to control the background color.
/// This is usually at the top most level of your View's body.
/// Note: If a view that has its own background set (like a list), you will need to explicitly hide that view's background.
struct ViewBackground<Content: View>: View {
    var color: Color = Color.appBackground
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            color
                .edgesIgnoringSafeArea(.all)
            HStack(content: content)
        }
    }
}

struct ViewBackground_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewBackground {
                List {
                    Text("View Background Preview")
                }
                .scrollContentBackground(.hidden)
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            ViewBackground {
                Text("View Background Preview")
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
