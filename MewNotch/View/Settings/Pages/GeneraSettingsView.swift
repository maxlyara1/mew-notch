//
//  GeneraSettingsView.swift
//  MewNotch
//
//  Created by Monu Kumar on 27/02/25.
//

import SwiftUI
import LaunchAtLogin

struct GeneraSettingsView: View {
    
    @StateObject var appDefaults = AppDefaults.shared
    @StateObject var notchDefaults = NotchDefaults.shared
    
    @ObservedObject var settingsViewModel: SettingsViewModel = .init()
    
    var body: some View {
        SettingsPage(
            title: "General",
            subtitle: "Core app behavior and system integration."
        ) {
            SettingsSection(
                title: "App",
                subtitle: "Startup and menu bar presence."
            ) {
                SettingsRow(
                    title: "Launch at Login",
                    subtitle: "Start automatically when you sign in."
                ) {
                    LaunchAtLogin.Toggle()
                        .labelsHidden()
                }
                
                SettingsRow(
                    title: "Status Icon",
                    subtitle: "Show MewNotch in the menu bar."
                ) {
                    Toggle("", isOn: $appDefaults.showMenuIcon)
                        .labelsHidden()
                }
            }
            
            SettingsSection(
                title: "System",
                subtitle: "Control native HUD behavior."
            ) {
                SettingsRow(
                    title: "Disable system HUD",
                    subtitle: "Use MewNotch as the primary system HUD."
                ) {
                    Toggle("", isOn: $appDefaults.disableSystemHUD)
                        .labelsHidden()
                        .onChange(
                            of: appDefaults.disableSystemHUD
                        ) { _, newValue in
                            if newValue {
                                OSDUIManager.shared.stop()
                            } else {
                                OSDUIManager.shared.start()
                            }
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(
                placement: .automatic
            ) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }
}

#Preview {
    GeneraSettingsView()
}
