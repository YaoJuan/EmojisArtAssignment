//
//  AnimatableSystemFontModifier.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/13.
//

import SwiftUI

struct AnimatableSystemFontModifier: AnimatableModifier {
    var fontSize: CGFloat
    var weight: Font.Weight = .regular
    var design: Font.Design = .default
    
    var animatableData: CGFloat {
        set {  fontSize = newValue }
        get { fontSize }
    }
    
    func body(content: Content) -> some View {
        content.font(Font.system(size: fontSize, weight: weight, design: design))
    }
}

extension View {
    func font(animatableWithSize size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        return self.modifier(AnimatableSystemFontModifier(fontSize: size, weight: weight, design: design))
    }
}
