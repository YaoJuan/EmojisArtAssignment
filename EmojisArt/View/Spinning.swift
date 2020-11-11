//
//  Spinning.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/19.
//

import SwiftUI

struct Spinning: ViewModifier {
    
    @State var isVisible: Bool = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false))
            .onAppear {
                self.isVisible = true
            }
    }
}


extension View {
    func spinning() -> some View {
        modifier(Spinning())
    }
}
