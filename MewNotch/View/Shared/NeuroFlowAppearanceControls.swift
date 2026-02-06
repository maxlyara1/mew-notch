//
//  NeuroFlowAppearanceControls.swift
//  MewNotch
//
//  Created by OpenAI Codex on 06/02/2026.
//

import SwiftUI

struct NeuroFlowColorPalette: View {
    @Binding var selection: NeuroFlowAccentColor

    private let columns = [
        GridItem(.adaptive(minimum: 22, maximum: 26), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(NeuroFlowAccentColor.presets, id: \.self) { preset in
                Button {
                    selection = preset
                } label: {
                    Circle()
                        .fill(preset.color)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(
                                    selection.isClose(to: preset)
                                    ? Color.white.opacity(0.95)
                                    : Color.white.opacity(0.18),
                                    lineWidth: selection.isClose(to: preset) ? 2 : 1
                                )
                        )
                        .shadow(
                            color: preset.color.opacity(selection.isClose(to: preset) ? 0.55 : 0.25),
                            radius: selection.isClose(to: preset) ? 7 : 3,
                            x: 0,
                            y: 0
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Accent color"))
            }
        }
    }
}

struct NeuroFlowGlowIntensityControl: View {
    @Binding var value: Double

    private let range: ClosedRange<Double> = 0.7...2.5

    var body: some View {
        HStack(spacing: 10) {
            Slider(value: $value, in: range, step: 0.05)
                .frame(minWidth: 120)
            Text(String(format: "%.2fx", value))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
    }
}

struct NeuroFlowBreathSpeedControl: View {
    @Binding var value: Double

    private let range: ClosedRange<Double> = 3.0...10.0

    var body: some View {
        HStack(spacing: 10) {
            Slider(value: $value, in: range, step: 0.1)
                .frame(minWidth: 120)
            Text(String(format: "%.1fs", value))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
    }
}
