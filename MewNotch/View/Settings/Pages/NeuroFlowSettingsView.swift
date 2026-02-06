//
//  NeuroFlowSettingsView.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import SwiftUI

struct NeuroFlowSettingsView: View {
    
    @StateObject private var neuroFlowDefaults = NeuroFlowDefaults.shared
    @StateObject private var neuroFlowManager = NeuroFlowManager.shared
    
    var body: some View {
        SettingsPage(
            title: "Neuro-Flow",
            subtitle: "Micro-pauses that help your brain replay what you just learned."
        ) {
            SettingsSection(
                title: "Status",
                subtitle: "Enable the focus → pause cycle."
            ) {
                SettingsRow(
                    title: "Enable Neuro-Flow",
                    subtitle: "Shows a pause overlay and notch timer." 
                ) {
                    Toggle("", isOn: $neuroFlowDefaults.isEnabled)
                        .labelsHidden()
                }
                
                Button("Start Break Now") {
                    neuroFlowManager.startBreakNow()
                }
                .buttonStyle(.borderedProminent)
                .tint(SettingsTheme.accent)
                .disabled(!neuroFlowDefaults.isEnabled)
            }
            
            SettingsSection(
                title: "Timing",
                subtitle: "Tune the rhythm for your study sessions."
            ) {
                SettingsRow(
                    title: "Focus duration",
                    subtitle: "Work time before a pause." 
                ) {
                    StepperControl(value: $neuroFlowDefaults.focusMinutes, unit: "min", range: 2...60)
                }
                
                SettingsRow(
                    title: "Break duration",
                    subtitle: "Length of each micro-break." 
                ) {
                    StepperControl(value: $neuroFlowDefaults.breakSeconds, unit: "sec", range: 5...60)
                }
                
                SettingsRow(
                    title: "Reset after inactivity",
                    subtitle: "If there is no input for this long, the focus timer resets." 
                ) {
                    StepperControl(value: $neuroFlowDefaults.idleResetSeconds, unit: "sec", range: 30...300, step: 10)
                }
            }
            
            SettingsSection(
                title: "Visuals",
                subtitle: "How the break looks on screen."
            ) {
                SettingsRow(
                    title: "Accent color",
                    subtitle: "Choose a preset glow color."
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
                    subtitle: "Soft chime when the pause starts and ends."
                ) {
                    Toggle("", isOn: $neuroFlowDefaults.playBreakSound)
                        .labelsHidden()
                }
            }
            
            SettingsSection(
                title: "How it works",
                subtitle: "Short pauses let the brain replay patterns at high speed."
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Focus \(neuroFlowDefaults.focusMinutes) min → Break \(neuroFlowDefaults.breakSeconds) sec")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    Text("You work for the focus duration, then the notch softly glows for the break.\nThe pause is soft (no input blocking) and can be skipped from the notch or menu.")
                        .font(SettingsTheme.secondaryFont)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var accentSelection: Binding<NeuroFlowAccentColor> {
        Binding(
            get: { neuroFlowDefaults.accentColor },
            set: { neuroFlowDefaults.accentColor = $0 }
        )
    }
}

private struct StepperControl: View {
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    var step: Int = 1
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(value) \(unit)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .frame(minWidth: 60, alignment: .trailing)
            Stepper("", value: $value, in: range, step: step)
                .labelsHidden()
        }
    }
}

#Preview {
    NeuroFlowSettingsView()
}
