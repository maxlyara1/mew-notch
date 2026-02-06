//
//  HUDAudioSettingsView.swift
//  MewNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct HUDAudioSettingsView: View {
    
    @StateObject var audioInputDefaults = HUDAudioInputDefaults.shared
    @StateObject var audioOutputDefaults = HUDAudioOutputDefaults.shared
    
    var body: some View {
        SettingsPage(
            title: "Audio",
            subtitle: "Visual feedback for input and output changes."
        ) {
            SettingsSection(
                title: "Input",
                subtitle: "Microphone level and device changes."
            ) {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Show input volume changes."
                ) {
                    Toggle("", isOn: $audioInputDefaults.isEnabled)
                        .labelsHidden()
                }
            }
            
            SettingsSection(
                title: "Output",
                subtitle: "Speaker volume and device changes."
            ) {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Show output volume changes."
                ) {
                    Toggle("", isOn: $audioOutputDefaults.isEnabled)
                        .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    HUDAudioSettingsView()
}
