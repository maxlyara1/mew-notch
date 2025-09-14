//
//  VideoHUDRightView.swift
//  MewNotch
//
//  Created by MewNotch Team on 15/09/25.
//

import SwiftUI

struct VideoHUDRightView: View {
    @ObservedObject var notchViewModel: NotchViewModel
    var hudModel: HUDPropertyModel?
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var pulseAnimation = false

    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "-:--" }
        let s = Int(seconds.rounded())
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }

    var body: some View {
        if let hudModel = hudModel {
            Group {
                let e = hudModel.elapsed ?? 0
                let d = hudModel.duration ?? 0
                let remain = (d.isFinite && e.isFinite && d > e) ? (d - e) : .nan

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 4, height: 4)
                        .opacity(pulseAnimation ? 0.3 : 1)
                        .scaleEffect(pulseAnimation ? 0.8 : 1)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: pulseAnimation)

                    Text(timeString(remain))
                        .font(.caption2.monospacedDigit().weight(.semibold))
                        .lineLimit(1)
                        .opacity(showContent ? 1 : 0)
                        .offset(x: showContent ? 0 : 20)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: notchViewModel.notchSize.height * 0.80)
            .padding(.vertical, notchViewModel.notchSize.height * 0.10)
            .background(
                Capsule()
                    .fill(.black.opacity(0.85))
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    )
                    .scaleEffect(isAnimating ? 1 : 0.3, anchor: .leading)
            )
            .foregroundStyle(.white)
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0.2, anchor: .leading)
                        .combined(with: .opacity)
                        .combined(with: .offset(x: -20)),
                    removal: .scale(scale: 0.2, anchor: .leading)
                        .combined(with: .opacity)
                )
            )
            .padding(.leading, 2)
            .zIndex(1)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isAnimating = true
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                    showContent = true
                }
                pulseAnimation = true
            }
            .onDisappear {
                isAnimating = false
                showContent = false
                pulseAnimation = false
            }
        }
    }
}
