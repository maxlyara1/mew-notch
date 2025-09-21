//
//  IslandHUDRightView.swift
//  MewNotch
//
//  Created by Monu Kumar on 11/03/25.
//

import SwiftUI

struct IslandHUDRightView<T: HUDDefaultsProtocol>: View {

    @ObservedObject var notchViewModel: NotchViewModel
    @ObservedObject var defaults: T

    var hudModel: HUDPropertyModel?

    var body: some View {
        if let hud = hudModel, defaults.isEnabled {
            IslandHUDView(
                notchViewModel: notchViewModel,
                variant: .right
            ) {
                HStack(spacing: 4) {
                    hud.getIcon()
                        .font(.title3)
                        .foregroundStyle(Color.white)

                    AnimatedTextView(
                        value: Double(hud.value * 100)
                    ) { value in
                        Text(
                            String(
                                format: "%02.0f",
                                value
                            )
                        )
                        .fixedSize(horizontal: true, vertical: false)
                        .font(
                            .title2.weight(
                                .semibold
                            )
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }
        }
    }
}
