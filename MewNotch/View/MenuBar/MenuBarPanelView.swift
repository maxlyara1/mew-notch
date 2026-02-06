//
//  MenuBarPanelView.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import SwiftUI

struct MenuBarPanelView: View {
    @Environment(\.openSettings) private var openSettings

    @StateObject private var appDefaults = AppDefaults.shared
    @StateObject private var neuroFlowDefaults = NeuroFlowDefaults.shared
    @StateObject private var neuroFlow = NeuroFlowManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            SettingsSection(title: "Neuro-Flow", subtitle: "Focus → Break cycle.") {
                SettingsRow(
                    title: "Enabled",
                    subtitle: nil
                ) {
                    Toggle("", isOn: $neuroFlowDefaults.isEnabled)
                        .labelsHidden()
                }

                SettingsRow(
                    title: "Accent color",
                    subtitle: nil
                ) {
                    NeuroFlowColorPalette(selection: accentSelection)
                        .frame(maxWidth: 140)
                }

                SettingsRow(
                    title: "Glow intensity",
                    subtitle: nil
                ) {
                    NeuroFlowGlowIntensityControl(value: $neuroFlowDefaults.glowIntensity)
                }

                SettingsRow(
                    title: "Breath pace",
                    subtitle: nil
                ) {
                    NeuroFlowBreathSpeedControl(value: $neuroFlowDefaults.breathPeriod)
                }

                HStack(spacing: 10) {
                    Button("Start Break") {
                        neuroFlow.startBreakNow()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SettingsTheme.accent)
                    .disabled(!neuroFlowDefaults.isEnabled)

                    if neuroFlow.isBreakActive {
                        Button("Skip") {
                            neuroFlow.skipBreak()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            SettingsSection(title: "Quick", subtitle: nil) {
                Toggle("Show menu icon", isOn: $appDefaults.showMenuIcon)
                Button("Open Settings") { openSettings() }
                Button("Fix Notch") { NotchManager.shared.refreshNotches() }
                if appDefaults.disableSystemHUD {
                    Button("Fix System HUD") { OSDUIManager.shared.reset() }
                }
                Divider()
                Button("Quit") { AppManager.shared.kill() }
            }
        }
        .padding(16)
        .frame(minWidth: 300, idealWidth: 340)
        .background(SettingsTheme.background)
    }

    private var accentSelection: Binding<NeuroFlowAccentColor> {
        Binding(
            get: { neuroFlowDefaults.accentColor },
            set: { neuroFlowDefaults.accentColor = $0 }
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            MewNotch.Assets.iconMenuBar
                .renderingMode(.template)
                .foregroundStyle(SettingsTheme.accent)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text("MewNotch")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("Notch control & focus")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(neuroFlowDefaults.isEnabled ? Color.green.opacity(0.8) : Color.gray.opacity(0.4))
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    MenuBarPanelView()
}
