//
//  HUDPowerSettingsView.swift
//  MewNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct HUDPowerSettingsView: View {
    
    @StateObject var powerDefaults = HUDPowerDefaults.shared
    
    var body: some View {
        SettingsPage(
            title: "Power",
            subtitle: "Battery and power-source changes."
        ) {
            SettingsSection(
                title: "Power HUD",
                subtitle: "Show charging and battery status."
            ) {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Display changes when plugging in or unplugging."
                ) {
                    Toggle("", isOn: $powerDefaults.isEnabled)
                        .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    HUDPowerSettingsView()
}
