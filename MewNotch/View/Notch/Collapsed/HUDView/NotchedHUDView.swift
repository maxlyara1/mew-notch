//
//  NotchedHUDView.swift
//  MewNotch
//
//  Created by Monu Kumar on 27/02/25.
//

import SwiftUI

import Lottie

struct NotchedHUDView<T: HUDDefaultsProtocol>: View {
    
    @ObservedObject var notchViewModel: NotchViewModel
    @ObservedObject var defaults: T
    
    var hudModel: HUDPropertyModel?
    
    var body: some View {
        if let hud = hudModel, defaults.isEnabled, defaults.style == .Notched && !notchViewModel.isExpanded {
            VStack {
                Rectangle()
                    .opacity(0)
                    .overlay {
                        hud.getIcon()
                    }
                
                RoundedRectangle(
                    cornerRadius: 2
                )
                .fill(
                    .white.opacity(
                        0.1
                    )
                )
                .frame(
                    height: 8
                )
                .overlay {
                    GeometryReader { geometry in
                        HStack(spacing: 6) {
                            RoundedRectangle(
                                cornerRadius: 2
                            )
                            .fill(
                                Color.accentColor
                            )
                            .frame(
                                width: max(0, CGFloat(hud.value) * geometry.size.width - 36),
                                height: geometry.size.height
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                            let remaining = max(0, 1 - CGFloat(hud.value))
                            Text(timeString(from: remaining))
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.white.opacity(0.9))
                                .frame(width: 30, alignment: .trailing)
                        }
                        .frame(
                            width: geometry.size.width,
                            alignment: .leading
                        )
                    }
                }
            }
            .padding(
                .init(
                    top: 0,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
            )
            .frame(
                width: notchViewModel.notchSize.width - notchViewModel.extraNotchPadSize.width,
                height: notchViewModel.notchSize.width - notchViewModel.notchSize.height - notchViewModel.extraNotchPadSize.width
            )
            .transition(
                .move(
                    edge: .top
                )
                .combined(
                    with: .opacity
                )
            )
        }
    }

    private func timeString(from progressRemaining: CGFloat) -> String {
        let total = 300.0
        let remain = Int(progressRemaining * total)
        let m = remain / 60
        let s = remain % 60
        return String(format: "%02d:%02d", m, s)
    }
}
