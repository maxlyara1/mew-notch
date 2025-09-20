//
//  MinimalHUDView.swift
//  MewNotch
//
//  Created by Monu Kumar on 05/06/25.
//

import SwiftUI

struct MinimalHUDView<Content: View>: View {
    
    enum Variant {
        case left
        case right
    }
    
    @ObservedObject var notchViewModel: NotchViewModel
    
    var variant: Variant
    
    var content: () -> Content
    
    var body: some View {
        let pad = notchViewModel.minimalHUDPadding
        let box = notchViewModel.notchSize.height
        let extra = notchViewModel.extraNotchPadSize.width / 2 + 6
        let isLeft = (variant == .left)
        
        return content()
            .padding(pad)
            .frame(width: box, height: box)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .transition(
                .move(edge: isLeft ? .trailing : .leading)
                    .combined(with: .opacity)
            )
            // Remove vertical push; keep only horizontal padding from notch
            .padding(.horizontal, extra)
    }
}
