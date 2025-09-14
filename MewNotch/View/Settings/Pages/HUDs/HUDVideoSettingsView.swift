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
        Form {
            Section {
                Toggle("Enabled", isOn: $defaults.isEnabled)

                // Only one style exposed (Island)
                Picker(selection: $defaults.style) {
                    Text("Island").tag(HUDStyle.Island)
                } label: {
                    Text("Style")
                }

                Toggle("Show only when video", isOn: $defaults.showOnlyWhenVideo)
                Toggle("Chromium only", isOn: $defaults.chromiumOnly)

                Toggle("Persistent edge overlay", isOn: $defaults.persistentEdgeOverlay)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Video")
    }
}

#Preview {
    HUDVideoSettingsView()
}


