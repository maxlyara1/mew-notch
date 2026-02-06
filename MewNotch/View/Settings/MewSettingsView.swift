//
//  MewSettingsView.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

struct MewSettingsView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    enum SettingsPages: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        
        case General
        case Notch
        case NeuroFlow
        
        case Brightness
        
        case Audio
//        case AudioOutput
//        case AudioInput

        case Power
        case Video
        
        case About
    }
    
    @StateObject var settingsViewModel: SettingsViewModel = .init()
    
    @StateObject var defaultsManager = MewDefaultsManager.shared
    
    @State var selectedPage: SettingsPages = .General
    
    var body: some View {
        NavigationSplitView(
            sidebar: {
                List(
                    selection: $selectedPage
                ) {
                    Section(
                        content: {
                            NavigationLink(
                                destination: {
                                    GeneraSettingsView(
                                        settingsViewModel: settingsViewModel
                                    )
                                }
                            ) {
                                Label(
                                    "General",
                                    systemImage: "gear"
                                )
                            }
                            .id(SettingsPages.General)
                            
                            
                            NavigationLink(
                                destination: {
                                    NotchSettingsView()
                                }
                            ) {
                                Label(
                                    title: {
                                        Text("Notch")
                                    },
                                    icon: {
                                        MewNotch.Assets.iconMenuBar
                                            .renderingMode(.template)
                                    }
                                )
                            }
                            .id(SettingsPages.Notch)
                            
                            NavigationLink(
                                destination: {
                                    NeuroFlowSettingsView()
                                }
                            ) {
                                Label(
                                    "Neuro-Flow",
                                    systemImage: "brain.head.profile"
                                )
                            }
                            .id(SettingsPages.NeuroFlow)
                        }
                    )
                    
                    Section(
                        content: {
                            NavigationLink(
                                destination: {
                                    HUDBrightnessSettingsView()
                                }
                            ) {
                                Label(
                                    "Brightness",
                                    systemImage: "rays"
                                )
                            }
                            .id(SettingsPages.Brightness)
                            
                            NavigationLink(
                                destination: {
                                    HUDAudioSettingsView()
                                }
                            ) {
                                Label(
                                    "Audio",
                                    systemImage: "waveform"
                                )
                            }
                            .id(SettingsPages.Audio)
                            
                            NavigationLink(
                                destination: {
                                    HUDPowerSettingsView()
                                }
                            ) {
                                Label(
                                    "Power",
                                    systemImage: "powerplug"
                                )
                            }
                            .id(SettingsPages.Power)

                            NavigationLink(
                                destination: {
                                    HUDVideoSettingsView()
                                }
                            ) {
                                Label(
                                    "Video",
                                    systemImage: "play.rectangle"
                                )
                            }
                            .id(SettingsPages.Video)
                        },
                        header: {
                            Text("HUD")
                        }
                    )
                    
                    Section {
                        NavigationLink(
                            destination: {
                                AboutAppView(
                                    settingsViewModel: settingsViewModel
                                )
                            }
                        ) {
                            Label(
                                "About",
                                systemImage: "info.circle"
                            )
                        }
                        .id(SettingsPages.About)
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .background(SettingsTheme.background)
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 320)
            },
            detail: {
                GeneraSettingsView(
                    settingsViewModel: settingsViewModel
                )
            }
        )
        .scrollContentBackground(.hidden)
        .background(SettingsTheme.background)
        .listStyle(.sidebar)
        .navigationSplitViewStyle(.balanced)
        .tint(SettingsTheme.accent)
        .task {
            guard let window = NSApp.windows.first(
                where: {
                    $0.identifier?.rawValue == "com_apple_SwiftUI_Settings_window"
                }
            ) else {
                return
            }
            
            window.toolbarStyle = .unified
            window.styleMask.insert(.resizable)
            window.minSize = NSSize(width: 760, height: 560)
            window.setContentSize(NSSize(width: 900, height: 600))
            
            NSApp.activate()
        }
    }
}

#Preview {
    MewSettingsView()
}
