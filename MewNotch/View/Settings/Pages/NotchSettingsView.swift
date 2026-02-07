//
//  NotchSettingsView.swift
//  MewNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct NotchSettingsView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var notchDefaults = NotchDefaults.shared
    
    @State var screens: [NSScreen] = []
    
    func refreshNSScreens() {
        withAnimation {
            self.screens = NSScreen.screens
        }
    }
    
    var body: some View {
        SettingsPage(
            title: "Notch",
            subtitle: "Where and how the notch behaves."
        ) {
            SettingsSection(
                title: "Displays",
                subtitle: "Choose where the notch should appear."
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Picker(
                        selection: $notchDefaults.notchDisplayVisibility,
                        content: {
                            ForEach(
                                NotchDisplayVisibility.allCases
                            ) { item in
                                Text(item.displayName)
                                    .tag(item)
                            }
                        }
                    ) {
                        Text("Show Notch On")
                    }
                    .pickerStyle(.segmented)
                    
                    if notchDefaults.notchDisplayVisibility == .Custom {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Choose Displays")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                Spacer()
                                Button(
                                    action: {
                                        self.refreshNSScreens()
                                    }
                                ) {
                                    Text("Refresh")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            
                            ScrollView(
                                .horizontal
                            ) {
                                LazyHStack(
                                    spacing: 12
                                ) {
                                    ForEach(
                                        self.screens,
                                        id: \.self
                                    ) { screen in
                                        let isSelected = notchDefaults.shownOnDisplay[screen.localizedName] == true
                                        
                                        Text(
                                            screen.localizedName
                                        )
                                        .padding(12)
                                        .frame(
                                            minHeight: 80
                                        )
                                        .background {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(isSelected ? SettingsTheme.accent.opacity(0.2) : Color.primary.opacity(0.05))
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(isSelected ? SettingsTheme.accent : Color.primary.opacity(0.08), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            let oldValue = notchDefaults.shownOnDisplay[screen.localizedName] ?? false
                                            
                                            withAnimation {
                                                notchDefaults.shownOnDisplay[screen.localizedName] = !oldValue
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            
            SettingsSection(
                title: "Interface",
                subtitle: "Shape and size alignment."
            ) {
                SettingsRow(
                    title: "Height",
                    subtitle: "Match the physical notch or the menu bar."
                ) {
                    Picker(
                        selection: $notchDefaults.heightMode,
                        content: {
                            Text(
                                NotchHeightMode.Match_Notch.rawValue.replacingOccurrences(
                                    of: "_",
                                    with: " "
                                )
                            )
                            .tag(
                                NotchHeightMode.Match_Notch
                            )
                            
                            Text(
                                NotchHeightMode.Match_Menu_Bar.rawValue.replacingOccurrences(
                                    of: "_",
                                    with: " "
                                )
                            )
                            .tag(
                                NotchHeightMode.Match_Menu_Bar
                            )
                        }
                    ) {
                        Text("Height")
                    }
                    .pickerStyle(.menu)
                }
            }
            
            SettingsSection(
                title: "Interaction",
                subtitle: "Hover and expansion behavior."
            ) {
                SettingsRow(
                    title: "Expand on Hover",
                    subtitle: "Expand after hovering for quick access."
                ) {
                    Toggle("", isOn: $notchDefaults.expandOnHover)
                        .labelsHidden()
                }
            }
            
            SettingsSection(
                title: "Expanded Notch",
                subtitle: "Customize what appears when expanded."
            ) {
                SettingsRow(
                    title: "Show Dividers",
                    subtitle: "Display separators between expanded items."
                ) {
                    Toggle("", isOn: $notchDefaults.showDividers)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(
                        ExpandedNotchItem.allCases
                    ) { item in
                        Toggle(
                            isOn: .init(
                                get: { notchDefaults.expandedNotchItems.contains(item) },
                                set: { isEnabled in
                                    if isEnabled {
                                        notchDefaults.expandedNotchItems.insert(item)
                                    } else {
                                        notchDefaults.expandedNotchItems.remove(item)
                                    }
                                }
                            )
                        ) {
                            Text(item.displayName)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            refreshNSScreens()
        }
    }
}

#Preview {
    NotchSettingsView()
}
