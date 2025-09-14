//
//  BrowserVideoProbe.swift
//  MewNotch
//
//  Created by MewNotch Team on 14/09/25.
//

import Cocoa

extension NSNotification.Name {
    static let BrowserVideoProgress = NSNotification.Name("BrowserVideoProgress")
}

/// Lightweight AppleScript-based probe for video progress in frontmost browser tab.
/// Fallback when MediaRemote provides no reliable video info.
final class BrowserVideoProbe {
    static let shared = BrowserVideoProbe()
    private var timer: Timer?
    private init() {}

    // Last sampled values (for UI)
    private(set) var lastElapsed: Double = .nan
    private(set) var lastDuration: Double = .nan
    private(set) var lastIsPlaying: Bool = false
    private(set) var lastBundle: String = ""

    func start() {
        timer?.invalidate()
        timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let app = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""

        // Only try scripting for known browsers; still tick fallback even if not a browser
        let isBrowser = app.contains("com.apple.Safari") || app.contains("com.google.Chrome") || app.lowercased().contains("yandex") || app.lowercased().contains("chromium") || app.lowercased().contains("comet")

        if !app.isEmpty {
            NSLog("BrowserVideoProbe tick: frontmost=%@", app)
        }

        let scriptSource: String
        if isBrowser && app.contains("com.apple.Safari") {
            // Use current tab of front window for Safari
            scriptSource = """
            tell application "Safari"
                if (count of windows) = 0 then return ""
                tell current tab of front window
                    do JavaScript "(() => { const vs = Array.from(document.querySelectorAll('video')).filter(v => v.duration > 0 && v.readyState > 2); const v = vs.sort((a, b) => b.clientWidth - a.clientWidth)[0]; if (!v) return ''; const d=v.duration||0; const e=v.currentTime||0; const p=(!v.paused && !v.ended)?1:0; return e+'|'+d+'|'+p; })()"
                end tell
            end tell
            """
        } else if isBrowser {
            // Chrome/Chromium/Comet/Yandex: same JS via AppleScript
            scriptSource = """
            tell application id \"\(app)\"
                if (count of windows) = 0 then return ""
                tell active tab of front window
                    execute javascript "(() => { const vs = Array.from(document.querySelectorAll('video')).filter(v => v.duration > 0 && v.readyState > 2); const v = vs.sort((a, b) => b.clientWidth - a.clientWidth)[0]; if (!v) return ''; const d=v.duration||0; const e=v.currentTime||0; const p=(!v.paused && !v.ended)?1:0; return e+'|'+d+'|'+p; })()"
                end tell
            end tell
            """
        } else {
            scriptSource = ""
        }

        if !scriptSource.isEmpty, let result = runAppleScript(scriptSource), !result.isEmpty {
            let parts = result.split(separator: "|")
            if parts.count == 3, let e = Double(parts[0]), let d = Double(parts[1]), let play = Int(parts[2]) {
                if d > 0 {
                    NSLog("BrowserVideoProbe: %@ e=%.2f d=%.2f p=%d", app, e, d, play)
                    self.lastElapsed = e
                    self.lastDuration = d
                    self.lastIsPlaying = (play == 1)
                    self.lastBundle = app
                    NotificationCenter.default.post(name: .BrowserVideoProgress, object: nil, userInfo: [
                        "bundle": app,
                        "elapsed": e,
                        "duration": d,
                        "playing": play == 1
                    ])
                } else {
                    // Invalidate if duration is zero
                    self.lastIsPlaying = false
                }
            }
        } else {
            if isBrowser { NSLog("BrowserVideoProbe: no result for %@", app) }
            // When we can't get fresh data from browser, send current state
            // This ensures UI gets updated with paused state
            if lastDuration.isFinite && lastDuration > 0 {
                NotificationCenter.default.post(name: .BrowserVideoProgress, object: nil, userInfo: [
                    "bundle": lastBundle,
                    "elapsed": lastElapsed,
                    "duration": lastDuration,
                    "playing": false  // No script result means video is likely paused/stopped
                ])
            }
        }
    }

    private func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            let output = script.executeAndReturnError(&error)
            if error == nil {
                return output.stringValue
            } else {
                NSLog("BrowserVideoProbe AppleScript error: %@", error?.description ?? "unknown")
            }
        }
        return nil
    }
}


