//
//  VideoOverlayHUDView.swift
//  MewNotch
//
//  Created by MewNotch Team on 15/09/25.
//

import SwiftUI

struct VideoOverlayHUDView: View {
    @ObservedObject var notchViewModel: NotchViewModel
    var hudModel: HUDPropertyModel?
    @State private var progressAnimation = false

    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "--:--" }
        let s = max(0, Int(seconds.rounded()))
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }

    var body: some View {
        if HUDVideoDefaults.shared.persistentEdgeOverlay, HUDVideoDefaults.shared.isEnabled, !notchViewModel.isExpanded {
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(.white.opacity(0.08))
                            .frame(height: 3)
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.05), lineWidth: 0.5)
                            )

                        let e = hudModel?.elapsed ?? .nan
                        let d = hudModel?.duration ?? .nan
                        let progress = (e.isFinite && d.isFinite && d > 0) ? min(1, max(0, e / d)) : 0

                        // Progress bar with gradient
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: CGFloat(progress) * geo.size.width, height: 3)
                            .overlay(
                                // Glow effect at the end
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .blur(radius: 2)
                                    .opacity(progressAnimation ? 0.8 : 0.4)
                                    .offset(x: CGFloat(progress) * geo.size.width - 3)
                                    .animation(.easeInOut(duration: 1).repeatForever(), value: progressAnimation)
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: progress)
                    }
                }
                .frame(height: 3)

                HStack(spacing: 4) {
                    let e = hudModel?.elapsed ?? .nan
                    let d = hudModel?.duration ?? .nan
                    let remain = (d.isFinite && e.isFinite && d > e) ? (d - e) : .nan

                    Text(timeString(e))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))
                        .opacity(e.isFinite ? 1 : 0.4)

                    Spacer()

                    HStack(spacing: 2) {
                        Text("-")
                            .font(.system(size: 8, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(timeString(remain))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .opacity(remain.isFinite ? 1 : 0.4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .frame(
                width: min(200, notchViewModel.notchSize.width - notchViewModel.extraNotchPadSize.width)
            )
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
            .scaleEffect(progressAnimation ? 1 : 0.95)
            .onAppear {
                progressAnimation = true
            }
            .onDisappear {
                progressAnimation = false
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progressAnimation)
        }
    }
}


