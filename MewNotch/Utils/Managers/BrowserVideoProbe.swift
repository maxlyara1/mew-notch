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
    
    // Local tracking for continuous updates
    private var localElapsed: Double = .nan
    private var localDuration: Double = .nan
    private var localIsPlaying: Bool = false
    private var localBundle: String = ""
    private var lastUpdateTime: Date = Date()
    private var isVideoActive: Bool = false

    func start() {
        timer?.invalidate()
        
        timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateVideoProgress()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isVideoActive = false
    }

    private func updateVideoProgress() {
        let app = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
        let isBrowser = app.contains("com.apple.Safari") || app.contains("com.google.Chrome") || app.lowercased().contains("yandex") || app.lowercased().contains("chromium") || app.lowercased().contains("comet")

        if !app.isEmpty {
            NSLog("BrowserVideoProbe: checking %@", app)
        }

        // Try to get fresh data from browser
        var gotFreshData = false
        if isBrowser {
            let scriptSource: String
            if app.contains("com.apple.Safari") {
                scriptSource = """
                tell application "Safari"
                    if (count of windows) = 0 then return ""
                    tell current tab of front window
                        do JavaScript "(() => { const vs = Array.from(document.querySelectorAll('video')).filter(v => v.duration > 0 && v.readyState > 2); const v = vs.sort((a, b) => b.clientWidth - a.clientWidth)[0]; if (!v) return ''; const d=v.duration||0; const e=v.currentTime||0; const p=(!v.paused && !v.ended)?1:0; return e+'|'+d+'|'+p; })()"
                    end tell
                end tell
                """
            } else {
                scriptSource = """
                tell application id \"\(app)\"
                    if (count of windows) = 0 then return ""
                    tell active tab of front window
                        execute javascript "(() => { const vs = Array.from(document.querySelectorAll('video')).filter(v => v.duration > 0 && v.readyState > 2); const v = vs.sort((a, b) => b.clientWidth - a.clientWidth)[0]; if (!v) return ''; const d=v.duration||0; const e=v.currentTime||0; const p=(!v.paused && !v.ended)?1:0; return e+'|'+d+'|'+p; })()"
                    end tell
                end tell
                """
            }

            if !scriptSource.isEmpty, let result = runAppleScript(scriptSource), !result.isEmpty {
                let parts = result.split(separator: "|")
                if parts.count == 3, let e = Double(parts[0]), let d = Double(parts[1]), let play = Int(parts[2]) {
                    if d > 0 {
                        NSLog("BrowserVideoProbe: fresh data - elapsed=%.2f duration=%.2f playing=%d", e, d, play)
                        
                        // Update all values
                        self.lastElapsed = e
                        self.lastDuration = d
                        self.lastIsPlaying = (play == 1)
                        self.lastBundle = app
                        
                        // Update local tracking
                        self.localElapsed = e
                        self.localDuration = d
                        self.localIsPlaying = (play == 1)
                        self.localBundle = app
                        self.lastUpdateTime = Date()
                        self.isVideoActive = true
                        
                        // Send notification
                        self.sendNotification()
                        
                        gotFreshData = true
                    } else {
                        // No video found
                        self.isVideoActive = false
                        self.lastIsPlaying = false
                        self.localIsPlaying = false
                        gotFreshData = true
                    }
                }
            }
        }
        
        // If no fresh data, use local tracking
        if !gotFreshData {
            if isVideoActive && localDuration.isFinite && localDuration > 0 {
                NSLog("BrowserVideoProbe: using local data - elapsed=%.2f duration=%.2f playing=%d", localElapsed, localDuration, localIsPlaying ? 1 : 0)
                
                // Update elapsed time if playing
                let now = Date()
                let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)
                
                if localIsPlaying {
                    localElapsed += timeSinceLastUpdate
                    
                    // Don't exceed duration
                    if localElapsed > localDuration {
                        localElapsed = localDuration
                        localIsPlaying = false
                    }
                }
                
                // Update public values
                lastElapsed = localElapsed
                lastDuration = localDuration
                lastIsPlaying = localIsPlaying
                lastBundle = localBundle
                lastUpdateTime = now
                
                // Send notification
                sendNotification()
            } else {
                // No video active
                if isVideoActive {
                    NSLog("BrowserVideoProbe: video ended")
                    isVideoActive = false
                    lastIsPlaying = false
                    localIsPlaying = false
                    sendNotification()
                }
            }
        }
    }
    
    private func sendNotification() {
        NotificationCenter.default.post(name: .BrowserVideoProgress, object: nil, userInfo: [
            "bundle": lastBundle,
            "elapsed": lastElapsed,
            "duration": lastDuration,
            "playing": lastIsPlaying
        ])
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