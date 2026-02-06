//
//  SettingsLayout.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import AppKit
import SwiftUI

enum SettingsTheme {
    static let background = LinearGradient(
        colors: [
            Color(nsColor: .windowBackgroundColor),
            Color(nsColor: .controlBackgroundColor)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardFill = Color(nsColor: .controlBackgroundColor).opacity(0.9)
    static let cardStroke = Color.primary.opacity(0.08)
    static let accent = Color(red: 0.12, green: 0.58, blue: 0.72)
    
    static let titleFont = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let sectionTitleFont = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 14, weight: .regular, design: .rounded)
    static let secondaryFont = Font.system(size: 12, weight: .regular, design: .rounded)
}

struct SettingsPage<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(SettingsTheme.titleFont)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(SettingsTheme.secondaryFont)
                            .foregroundStyle(.secondary)
                    }
                }
                
                content
            }
            .padding(24)
        }
        .background(SettingsTheme.background.ignoresSafeArea())
        .environment(\.font, SettingsTheme.bodyFont)
        .tint(SettingsTheme.accent)
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(SettingsTheme.sectionTitleFont)
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                
                if let subtitle {
                    Text(subtitle)
                        .font(SettingsTheme.secondaryFont)
                        .foregroundStyle(.secondary)
                }
            }
            
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SettingsTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SettingsTheme.cardStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}

struct SettingsRow<Control: View>: View {
    let title: String
    let subtitle: String?
    let control: Control
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder control: () -> Control
    ) {
        self.title = title
        self.subtitle = subtitle
        self.control = control()
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
                if let subtitle {
                    Text(subtitle)
                        .font(SettingsTheme.secondaryFont)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            control
        }
        .padding(.vertical, 6)
    }
}
