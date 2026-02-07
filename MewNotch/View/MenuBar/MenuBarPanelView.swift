//
//  MenuBarPanelView.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import AppKit
import SwiftUI

struct MenuBarPanelView: View {
    @Environment(\.openSettings) private var openSettings

    @StateObject private var appDefaults = AppDefaults.shared
    @StateObject private var neuroFlowDefaults = NeuroFlowDefaults.shared
    @StateObject private var neuroFlow = NeuroFlowManager.shared
    @State private var didConfigureWindow = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard
                sessionCard
                timingSection
                visualsSection
                mediaSection
                appSection
            }
            .padding(18)
        }
        .scrollContentBackground(.hidden)
        .frame(minWidth: 360, idealWidth: 420, minHeight: 480, idealHeight: 640)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SettingsTheme.background)
        .background(MenuBarPanelWindowConfigurator(didConfigure: $didConfigureWindow))
        .environment(\.font, SettingsTheme.bodyFont)
        .tint(SettingsTheme.accent)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private var accentSelection: Binding<NeuroFlowAccentColor> {
        Binding(
            get: { neuroFlowDefaults.accentColor },
            set: { neuroFlowDefaults.accentColor = $0 }
        )
    }

    private var headerCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SettingsTheme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    SettingsTheme.accent.opacity(0.22),
                                    Color.primary.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .fill(SettingsTheme.accent.opacity(0.32))
                        .frame(width: 200, height: 200)
                        .blur(radius: 36)
                        .offset(x: 150, y: -130)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 34, height: 34)
                        MewNotch.Assets.iconMenuBar
                            .renderingMode(.template)
                            .foregroundStyle(SettingsTheme.accent)
                            .frame(width: 18, height: 18)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neuro-Flow")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Text("Micro-pauses that lock in learning.")
                            .font(SettingsTheme.secondaryFont)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 8)

                    Toggle("", isOn: $neuroFlowDefaults.isEnabled)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }

                HStack(spacing: 8) {
                    MenuChip(
                        title: neuroFlow.isBreakActive ? "Break active" : "Focus mode",
                        color: neuroFlow.isBreakActive ? Color.orange : Color.green
                    )
                    MenuChip(
                        title: "Focus \(neuroFlowDefaults.focusMinutes)m • Break \(neuroFlowDefaults.breakSeconds)s",
                        color: SettingsTheme.accent
                    )
                }
            }
            .padding(16)
        }
    }

    private var sessionCard: some View {
        let isBreak = neuroFlow.isBreakActive
        let accent = neuroFlowDefaults.accentColor.color
        let remaining = isBreak ? neuroFlow.breakRemaining : focusRemaining
        let progress = sessionProgress

        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SettingsTheme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(SettingsTheme.cardStroke, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accent.opacity(0.16),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Text(isBreak ? "BREAK" : "FOCUS")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(1.1)
                    Spacer()
                    Text(isBreak ? "Breathe & let it settle" : "Next pause soon")
                        .font(SettingsTheme.secondaryFont)
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text(timeString(remaining))
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                    Text(isBreak ? "left" : "to break")
                        .font(SettingsTheme.secondaryFont)
                        .foregroundStyle(.secondary)
                }

                NeuroFlowProgressBar(progress: progress, accent: accent)
                    .frame(height: 12)

                HStack(spacing: 10) {
                    Button {
                        neuroFlow.startBreakNow()
                    } label: {
                        Label("Start break", systemImage: "sparkles")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .disabled(!neuroFlowDefaults.isEnabled)

                    if neuroFlow.isBreakActive {
                        Button {
                            neuroFlow.skipBreak()
                        } label: {
                            Label("Skip", systemImage: "forward.end.alt")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(16)
        }
    }

    private var timingSection: some View {
        SettingsSection(
            title: "Timing",
            subtitle: "Set the focus and break rhythm."
        ) {
            SettingsRow(
                title: "Focus duration",
                subtitle: "How long you work before a pause."
            ) {
                MenuStepper(value: $neuroFlowDefaults.focusMinutes, unit: "min", range: 2...60)
            }

            SettingsRow(
                title: "Break duration",
                subtitle: "Length of the micro-break."
            ) {
                MenuStepper(value: $neuroFlowDefaults.breakSeconds, unit: "sec", range: 5...60)
            }
        }
    }

    private var visualsSection: some View {
        SettingsSection(
            title: "Visuals",
            subtitle: "How the notch glow feels."
        ) {
            SettingsRow(
                title: "Accent color",
                subtitle: "Choose a preset glow tone."
            ) {
                NeuroFlowColorPalette(selection: accentSelection)
                    .frame(maxWidth: 170)
            }

            SettingsRow(
                title: "Glow intensity",
                subtitle: "Brighter or softer halo."
            ) {
                NeuroFlowGlowIntensityControl(value: $neuroFlowDefaults.glowIntensity)
            }

            SettingsRow(
                title: "Breath pace",
                subtitle: "Seconds per cycle (lower = faster)."
            ) {
                NeuroFlowBreathSpeedControl(value: $neuroFlowDefaults.breathPeriod)
            }

            SettingsRow(
                title: "Break sound",
                subtitle: "Soft chime on start and end."
            ) {
                Toggle("", isOn: $neuroFlowDefaults.playBreakSound)
                    .labelsHidden()
            }
        }
    }

    private var mediaSection: some View {
        SettingsSection(
            title: "Media",
            subtitle: "Optionally pause audio/video during a break."
        ) {
            SettingsRow(
                title: "Pause media",
                subtitle: "Send a system pause on break start."
            ) {
                Toggle("", isOn: $neuroFlowDefaults.pauseMediaDuringBreak)
                    .labelsHidden()
            }

            SettingsRow(
                title: "Resume after",
                subtitle: "Play again when the break ends."
            ) {
                Toggle("", isOn: $neuroFlowDefaults.resumeMediaAfterBreak)
                    .labelsHidden()
                    .disabled(!neuroFlowDefaults.pauseMediaDuringBreak)
            }
        }
    }

    private var appSection: some View {
        SettingsSection(
            title: "App",
            subtitle: nil
        ) {
            Toggle("Show menu icon", isOn: $appDefaults.showMenuIcon)

            Button {
                openSettings()
            } label: {
                Label("Open Settings", systemImage: "gearshape")
            }

            Button {
                NotchManager.shared.refreshNotches()
            } label: {
                Label("Fix Notch", systemImage: "wand.and.stars")
            }

            if appDefaults.disableSystemHUD {
                Button {
                    OSDUIManager.shared.reset()
                } label: {
                    Label("Fix System HUD", systemImage: "speaker.wave.2")
                }
            }

            Divider()

            Button(role: .destructive) {
                AppManager.shared.kill()
            } label: {
                Label("Quit", systemImage: "power")
            }
        }
    }

    private var focusRemaining: TimeInterval {
        let target = TimeInterval(neuroFlowDefaults.focusMinutes * 60)
        return max(0, target - neuroFlow.focusElapsed)
    }

    private var sessionProgress: Double {
        if neuroFlow.isBreakActive {
            return max(0, min(1, 1 - neuroFlow.breakProgress))
        }
        return neuroFlow.focusProgress
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let mins = total / 60
        let secs = total % 60
        if mins >= 60 {
            let hours = mins / 60
            let rem = mins % 60
            return String(format: "%d:%02d:%02d", hours, rem, secs)
        }
        return String(format: "%d:%02d", mins, secs)
    }
}

private struct MenuChip: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.08))
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

private struct NeuroFlowProgressBar: View {
    let progress: Double
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(8, proxy.size.width * CGFloat(progress))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.9),
                                accent.opacity(0.45)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width)
                    .shadow(color: accent.opacity(0.5), radius: 8, x: 0, y: 0)
            }
        }
    }
}

private struct MenuStepper: View {
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    var step: Int = 1

    var body: some View {
        HStack(spacing: 8) {
            Text("\(value) \(unit)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .frame(minWidth: 62, alignment: .trailing)
            Stepper("", value: $value, in: range, step: step)
                .labelsHidden()
        }
    }
}

private struct MenuBarPanelWindowConfigurator: NSViewRepresentable {
    @Binding var didConfigure: Bool

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard !didConfigure, let window = nsView.window else { return }
        DispatchQueue.main.async {
            configure(window)
            didConfigure = true
        }
    }

    private func configure(_ window: NSWindow) {
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false

        window.styleMask.insert([.resizable, .fullSizeContentView])
        window.minSize = NSSize(width: 340, height: 440)
        window.setFrameAutosaveName("MewNotch.MenuBarPanel")

        window.collectionBehavior = [
            .fullScreenAuxiliary,
            .canJoinAllSpaces,
            .moveToActiveSpace
        ]

        window.level = .statusBar
    }
}

#Preview {
    MenuBarPanelView()
}
