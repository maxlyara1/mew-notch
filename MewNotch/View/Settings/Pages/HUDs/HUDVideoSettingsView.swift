//
//  HUDVideoSettingsView.swift
//  MewNotch
//
//  Created by MewNotch Team on 14/09/25.
//

import SwiftUI

struct HUDVideoSettingsView: View {
    @StateObject var defaults = HUDVideoDefaults.shared

    var body: some View {
        SettingsPage(
            title: "Video",
            subtitle: "Playback HUD and browser detection."
        ) {
            SettingsSection(
                title: "Video HUD",
                subtitle: "Control how playback appears in the notch."
            ) {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Show video playback in the notch."
                ) {
                    Toggle("", isOn: $defaults.isEnabled)
                        .labelsHidden()
                }

                SettingsRow(
                    title: "Only when video",
                    subtitle: "Hide when audio-only playback is detected."
                ) {
                    Toggle("", isOn: $defaults.showOnlyWhenVideo)
                        .labelsHidden()
                }

                SettingsRow(
                    title: "Chromium only",
                    subtitle: "Restrict detection to Chromium browsers."
                ) {
                    Toggle("", isOn: $defaults.chromiumOnly)
                        .labelsHidden()
                }

                SettingsRow(
                    title: "Persistent edge overlay",
                    subtitle: "Keep a subtle edge indicator visible."
                ) {
                    Toggle("", isOn: $defaults.persistentEdgeOverlay)
                        .labelsHidden()
                }

                SettingsRow(
                    title: "Frontmost only",
                    subtitle: "Only show the HUD when the browser is active."
                ) {
                    Toggle("", isOn: $defaults.frontmostOnly)
                        .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    HUDVideoSettingsView()
}
