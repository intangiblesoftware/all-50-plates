//
//  ViewBackground.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 6/25/23.
//

import SwiftUI

struct ViewBackground<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var overlay: (() -> AnyView?)?
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .edgesIgnoringSafeArea(.all)
            HStack(content: content)
            if let overlay = overlay?() {
                overlay
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct ViewBackground_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewBackground {
                Text("View Background Preview")
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
