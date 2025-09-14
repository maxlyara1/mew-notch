//
//  BundleAppNameProvider.swift
//  MewNotch
//
//  Created by MewNotch Team on 15/09/25.
//

import AppKit

enum BundleAppNameProvider {
    static func currentAppName() -> String {
        let bundle = BrowserVideoProbe.shared.lastBundle
        if let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundle }) {
            if let name = app.localizedName { return name }
        }
        // Fallback to parsed bundle id tail or generic label
        if !bundle.isEmpty {
            if let last = bundle.split(separator: ".").last { return String(last).capitalized }
        }
        return "Video"
    }
    
    static func currentAppIcon() -> NSImage {
        let bundle = BrowserVideoProbe.shared.lastBundle
        if !bundle.isEmpty,
           let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundle) {
            return NSWorkspace.shared.icon(forFile: appUrl.path)
        }
        // Fallback icon
        return NSImage(systemSymbolName: "play.display", accessibilityDescription: nil)!
    }
}


