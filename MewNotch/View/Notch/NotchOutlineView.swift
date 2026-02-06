//
//  NotchOutlineView.swift
//  MewNotch
//
//  Created by OpenAI Codex on 06/02/2026.
//

import SwiftUI

struct NotchOutlineView: View {
    @ObservedObject var notchViewModel: NotchViewModel
    var isHovered: Bool

    private var width: CGFloat {
        notchViewModel.notchSize.width + notchViewModel.extraNotchPadSize.width
    }

    private var height: CGFloat {
        notchViewModel.notchSize.height
    }

    private var outlineGradient: LinearGradient {
        let top = isHovered ? Color.black.opacity(0.45) : Color.black.opacity(0.6)
        let bottom = isHovered ? Color.black.opacity(0.2) : Color.black.opacity(0.35)
        return LinearGradient(
            colors: [top, bottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .fill(Color.black)

            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .stroke(outlineGradient, lineWidth: isHovered ? 1.4 : 1.0)

            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .stroke(Color.black.opacity(isHovered ? 0.55 : 0.45), lineWidth: isHovered ? 1.2 : 0.8)
            .blur(radius: isHovered ? 6 : 4)
            .offset(y: 0.5)
            .opacity(isHovered ? 0.4 : 0.25)
        }
        .frame(width: width, height: height)
        .scaleEffect(isHovered ? 1.02 : 1.0, anchor: .top)
        .shadow(
            color: Color.black.opacity(isHovered ? 0.4 : 0.25),
            radius: isHovered ? 10 : 6,
            x: 0,
            y: isHovered ? 6 : 4
        )
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2),
            value: isHovered
        )
        .drawingGroup()
    }
}

#Preview {
    NotchOutlineView(
        notchViewModel: .init(screen: NSScreen.screens.first!),
        isHovered: true
    )
}
