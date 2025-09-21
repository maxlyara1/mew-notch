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
        Form {
            Section(
                content: {
                    Toggle("Enabled", isOn: $audioInputDefaults.isEnabled)

                },
                header: {
                    Text("Input")
                }
            )
            
            Section(
                content: {
                    Toggle("Enabled", isOn: $audioOutputDefaults.isEnabled)

                },
                header: {
                    Text("Output")
                }
            )
        }
        .formStyle(.grouped)
        .navigationTitle("Audio")
    }
}

#Preview {
    HUDAudioSettingsView()
}
