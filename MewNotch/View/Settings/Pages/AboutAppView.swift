//
//  AboutAppView.swift
//  MewNotch
//
//  Created by Monu Kumar on 27/02/25.
//

import SwiftUI

struct AboutAppView: View {
    
    @Environment(\.openURL) private var openURL
    
    @ObservedObject var settingsViewModel: SettingsViewModel = .init()
    
    var body: some View {
        SettingsPage(
            title: "About",
            subtitle: "Version info and updates."
        ) {
            SettingsSection(
                title: "App",
                subtitle: "Current build information."
            ) {
                SettingsRow(
                    title: "Version",
                    subtitle: nil
                ) {
                    Text(settingsViewModel.currentAppVersion)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
            }
            
            SettingsSection(
                title: "Latest Release",
                subtitle: "Check GitHub for updates."
            ) {
                HStack {
                    Text("Status")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    Spacer()
                    if settingsViewModel.isLoadingLatestRelease {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Button("Check for Updates") {
                            settingsViewModel.refreshLatestRelease()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
                if let latestRelease = settingsViewModel.latestRelease {
                    SettingsRow(
                        title: "Version",
                        subtitle: nil
                    ) {
                        Text(latestRelease.tagName)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    
                    if let publishedAt = latestRelease.publishedAt {
                        SettingsRow(
                            title: "Released",
                            subtitle: nil
                        ) {
                            Text(
                                publishedAt.formatted(
                                    format: "dd MMM yyyy, hh:mm a"
                                )
                            )
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                    }
                    
                    if !latestRelease.assets.isEmpty {
                        HStack {
                            Text("Download")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                            Spacer()
                            ForEach(
                                latestRelease.assets,
                                id: \.name
                            ) { asset in
                                if let url = URL(
                                    string: asset.browserDownloadUrl
                                ) {
                                    Button(
                                        asset.name,
                                        action: {
                                            openURL(url)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    if let url = URL(
                        string: "https://github.com/monuk7735/mew-notch"
                    ) {
                        HStack {
                            Text("Source Code")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                            Spacer()
                            Button(
                                "View on GitHub",
                                action: {
                                    openURL(url)
                                }
                            )
                        }
                    }
                } else if settingsViewModel.didFailToLoadLatestRelease {
                    Text("Failed to load latest release.")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    AboutAppView()
}
