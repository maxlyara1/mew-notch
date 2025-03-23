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

                    Picker(
                        selection: $audioInputDefaults.style,
                        content: {
                            ForEach(
                                HUDStyle.allCases
                            ) { style in
                                Text(style.rawValue.capitalized)
                                    .tag(style)
                            }
                        }
                    ) {
                        VStack(
                            alignment: .leading
                        ) {
                            Text("Style")

                            Text("Design to be used for HUD")
                                .font(.footnote)
                        }
                    }
                    .disabled(!audioInputDefaults.isEnabled)
                },
                header: {
                    Text("Input")
                }
            )
            
            Section(
                content: {
                    Toggle("Enabled", isOn: $audioOutputDefaults.isEnabled)

                    Picker(
                        selection: $audioOutputDefaults.style,
                        content: {
                            ForEach(
                                HUDStyle.allCases
                            ) { style in
                                Text(style.rawValue.capitalized)
                                    .tag(style)
                            }
                        }
                    ) {
                        VStack(
                            alignment: .leading
                        ) {
                            Text("Style")

                            Text("Design to be used for HUD")
                                .font(.footnote)
                        }
                    }
                    .disabled(!audioInputDefaults.isEnabled)
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
