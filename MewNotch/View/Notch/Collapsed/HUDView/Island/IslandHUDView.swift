//
//  IslandHUDView.swift
//  MewNotch
//
//  Created by Monu Kumar on 05/06/25.
//

import SwiftUI

struct IslandHUDView<Content: View>: View {

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
        let extra = notchViewModel.extraNotchPadSize.width / 2 + 8
        let isLeft = (variant == .left)

        let backgroundView = RoundedRectangle(cornerRadius: 16)
            .fill(.black.opacity(0.85))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.1), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )

        let insertionTransition = AnyTransition.scale(scale: 1.5, anchor: .center)
            .combined(with: .opacity)
            .combined(with: .offset(x: isLeft ? -40 : 40, y: 0))

        let removalTransition = AnyTransition.scale(scale: 0.1, anchor: .center)
            .combined(with: .opacity)
            .combined(with: .offset(x: isLeft ? -30 : 30, y: 0))

        return content()
            .padding(pad)
            .frame(width: box, height: box)
            .background(backgroundView)
            .transition(.asymmetric(insertion: insertionTransition, removal: removalTransition))
            .animation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.2))
            .rotationEffect(.degrees(360))
            .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.2), value: UUID())
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.4), value: UUID())
            .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 4)
            .padding(.horizontal, extra)
            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1), value: pad)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: notchViewModel.notchSize)
    }
}
