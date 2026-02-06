//
//  NeuroFlowNotchOverlayView.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import SwiftUI

struct NeuroFlowNotchOverlayView: View {
    
    @ObservedObject var neuroFlow: NeuroFlowManager
    @ObservedObject var notchViewModel: NotchViewModel
    @StateObject private var defaults = NeuroFlowDefaults.shared
    @State private var showOverlay: Bool = false
    @State private var overlayOpacity: Double = 0
    @State private var fadeToken = UUID()

    private let fadeInDuration: Double = 0.35
    private let fadeOutDuration: Double = 1.4
    
    var body: some View {
        let notchWidth = notchViewModel.notchSize.width + notchViewModel.extraNotchPadSize.width
        let notchHeight = notchViewModel.notchSize.height
        
        ZStack(alignment: .top) {
            if showOverlay {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                    let pulse = pulseValue(at: timeline.date)
                    let phase = phaseValue(at: timeline.date)
                    pulseOutline(pulse: pulse, phase: phase)
                }
                .opacity(overlayOpacity)
            }
        }
        .frame(
            width: notchWidth,
            height: notchHeight,
            alignment: .top
        )
        .onAppear {
            syncOverlayState()
        }
        .onChange(of: neuroFlow.isBreakActive) { _ in
            syncOverlayState()
        }
    }

    private func syncOverlayState() {
        if neuroFlow.isBreakActive {
            showOverlay = true
            fadeToken = UUID()
            withAnimation(.easeInOut(duration: fadeInDuration)) {
                overlayOpacity = 1
            }
        } else {
            let token = UUID()
            fadeToken = token
            withAnimation(.easeOut(duration: fadeOutDuration)) {
                overlayOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration) {
                guard token == fadeToken, !neuroFlow.isBreakActive else { return }
                showOverlay = false
            }
        }
    }
    
    private func pulseOutline(pulse: Double, phase: Double) -> some View {
        let intensity = clamp(defaults.glowIntensity, min: 0.7, max: 2.5)
        let gradient = flowGradient(pulse: pulse, phase: phase)
        let glowGradient = flowGradient(pulse: min(pulse + 0.25, 1.0), phase: phase + 70)
        let bloomGradient = flowGradient(pulse: min(pulse + 0.35, 1.0), phase: phase + 140)
        let widthScale = 0.9 + 0.4 * intensity
        let blurScale = 0.95 + 0.45 * intensity
        let coreWidth: CGFloat = 8 * widthScale
        let midWidth: CGFloat = 28 * widthScale
        let outerWidth: CGFloat = 56 * widthScale
        let bloomWidth: CGFloat = 96 * widthScale
        let coreBlur: CGFloat = 9 * blurScale
        let midBlur: CGFloat = 24 * blurScale
        let outerBlur: CGFloat = 54 * blurScale
        let bloomBlur: CGFloat = 86 * blurScale
        let coreOpacity = glowOpacity(0.82 + 0.3 * pulse, intensity: intensity)
        let midOpacity = glowOpacity(0.6 + 0.34 * pulse, intensity: intensity)
        let outerOpacity = glowOpacity(0.42 + 0.32 * pulse, intensity: intensity)
        let bloomOpacity = glowOpacity(0.28 + 0.28 * pulse, intensity: intensity)

        return ZStack {
            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .stroke(gradient, lineWidth: coreWidth)
            .opacity(coreOpacity)
            .blur(radius: coreBlur)
            .blendMode(.plusLighter)

            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .stroke(glowGradient, lineWidth: midWidth)
            .opacity(midOpacity)
            .blur(radius: midBlur)
            .blendMode(.plusLighter)

            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .stroke(glowGradient, lineWidth: outerWidth)
            .opacity(outerOpacity)
            .blur(radius: outerBlur)
            .blendMode(.plusLighter)

            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .stroke(bloomGradient, lineWidth: bloomWidth)
            .opacity(bloomOpacity)
            .blur(radius: bloomBlur)
            .blendMode(.plusLighter)

            NotchShape(
                topRadius: notchViewModel.cornerRadius.top,
                bottomRadius: notchViewModel.cornerRadius.bottom
            )
            .fill(Color.black)
            .blur(radius: 2.8)
            .blendMode(.destinationOut)
        }
        .compositingGroup()
        .scaleEffect(1.0 + 0.01 * pulse, anchor: .center)
    }

    private func flowGradient(pulse: Double, phase: Double) -> AngularGradient {
        let accentValue = defaults.accentColor
        let accent = accentValue.color
        let highlight = highlightColor(from: accentValue, pulse: pulse)
        let hot = hotColor(from: accentValue, pulse: pulse)
        let base = 0.24 + 0.12 * pulse
        let mid = 0.7 + 0.2 * pulse
        let peak = 1.0
        let band = 0.14 + 0.06 * pulse
        let tail = 0.42 + 0.14 * pulse
        let lead = 0.3 + 0.05 * pulse
        let hotBand = 0.04 + 0.014 * pulse

        let start = clamp(lead - band)
        let end = clamp(lead + band)
        let tailStart = clamp(lead - tail * 0.8)
        let tailEnd = clamp(lead + tail)
        let hotStart = clamp(lead - hotBand)
        let hotEnd = clamp(lead + hotBand)

        let stops = [
            Gradient.Stop(color: accent.opacity(base * 0.55), location: 0.0),
            Gradient.Stop(color: accent.opacity(base), location: tailStart),
            Gradient.Stop(color: accent.opacity(mid), location: start),
            Gradient.Stop(color: highlight.opacity(peak * 0.9), location: hotStart),
            Gradient.Stop(color: hot.opacity(peak), location: lead),
            Gradient.Stop(color: highlight.opacity(peak * 0.9), location: hotEnd),
            Gradient.Stop(color: accent.opacity(mid), location: end),
            Gradient.Stop(color: accent.opacity(base), location: tailEnd),
            Gradient.Stop(color: accent.opacity(base * 0.55), location: 1.0)
        ]

        return AngularGradient(
            gradient: Gradient(stops: stops),
            center: .center,
            angle: .degrees(phase)
        )
    }

    private func pulseValue(at date: Date) -> Double {
        let t = date.timeIntervalSinceReferenceDate
        let period = clamp(defaults.breathPeriod, min: 3.0, max: 10.0)
        let omega = (2.0 * Double.pi) / period
        let raw = 0.5 - 0.5 * cos(t * omega)
        let smooth = raw * raw * raw * (raw * (raw * 6.0 - 15.0) + 10.0)
        return clamp(0.06 + 0.94 * smooth)
    }

    private func phaseValue(at date: Date) -> Double {
        let t = date.timeIntervalSinceReferenceDate
        let base = t * 42.0
        let drift = 8.0 * sin(t * 0.08)
        return base + drift
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }

    private func clamp(_ value: Double, min minValue: Double, max maxValue: Double) -> Double {
        Swift.min(Swift.max(value, minValue), maxValue)
    }

    private func glowOpacity(_ value: Double, intensity: Double) -> Double {
        clamp(value * (0.9 + 0.75 * intensity))
    }

    private func highlightColor(from accent: NeuroFlowAccentColor, pulse: Double) -> Color {
        let mix = 0.5 + 0.22 * pulse
        let red = accent.red + (1.0 - accent.red) * mix
        let green = accent.green + (1.0 - accent.green) * mix
        let blue = accent.blue + (1.0 - accent.blue) * mix
        return Color(.sRGB, red: clamp(red), green: clamp(green), blue: clamp(blue), opacity: 1.0)
    }

    private func hotColor(from accent: NeuroFlowAccentColor, pulse: Double) -> Color {
        let mix = 0.9 + 0.08 * pulse
        let red = accent.red + (1.0 - accent.red) * mix
        let green = accent.green + (1.0 - accent.green) * mix
        let blue = accent.blue + (1.0 - accent.blue) * mix
        return Color(.sRGB, red: clamp(red), green: clamp(green), blue: clamp(blue), opacity: 1.0)
    }
}

#Preview {
    NeuroFlowNotchOverlayView(
        neuroFlow: NeuroFlowManager.shared,
        notchViewModel: .init(screen: NSScreen.screens.first!)
    )
}
