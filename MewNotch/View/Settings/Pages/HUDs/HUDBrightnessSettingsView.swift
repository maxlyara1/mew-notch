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
        Form {
            Section(
                content: {
                    Toggle(
                        "Enabled",
                        isOn: $brightnessDefaults.isEnabled
                    )

                    
                    Toggle(
                        "Show Auto Brightness Changes",
                        isOn: $brightnessDefaults.showAutoBrightnessChanges
                    )
                }
            )
        }
        .formStyle(.grouped)
        .navigationTitle("Brightness")
    }
}

#Preview {
    HUDBrightnessSettingsView()
}
