//
//  AnimatedNumberTextView.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

struct AnimatedTextView<Content>: View, Animatable where Content: View {
    
    var value: Double
    
    var content: (Double) -> Content
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        content(
            value
        )
        .animation(
            .spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0.05),
            value: value
        )
    }
}
