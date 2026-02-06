//
//  HUDBrightnessSettingsView.swift
//  MewNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct HUDBrightnessSettingsView: View {
    
    @StateObject var brightnessDefaults = HUDBrightnessDefaults.shared
    
    var body: some View {
        SettingsPage(
            title: "Brightness",
            subtitle: "Visual feedback for screen brightness changes."
        ) {
            SettingsSection(
                title: "Brightness HUD",
                subtitle: "Control when the HUD appears."
            ) {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Show brightness changes in the notch."
                ) {
                    Toggle("", isOn: $brightnessDefaults.isEnabled)
                        .labelsHidden()
                }
                
                SettingsRow(
                    title: "Auto Brightness",
                    subtitle: "Show changes triggered by ambient light."
                ) {
                    Toggle("", isOn: $brightnessDefaults.showAutoBrightnessChanges)
                        .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    HUDBrightnessSettingsView()
}
