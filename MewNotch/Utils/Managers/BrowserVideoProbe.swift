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
    private var isManuallyPaused: Bool = false
    private var globalKeyMonitors: [Any] = []

    func start() {
        timer?.invalidate()

        // Start global key monitoring for multiple key types
        startGlobalKeyMonitoring()

        timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateVideoProgress()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isVideoActive = false
        isManuallyPaused = false

        // Stop global key monitoring
        stopGlobalKeyMonitoring()
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
                        // If manually paused, show as paused regardless of browser state
                        self.lastIsPlaying = (play == 1) && !self.isManuallyPaused
                        self.lastBundle = app
                        
                        // Update local tracking
                        self.localElapsed = e
                        self.localDuration = d
                        self.localIsPlaying = (play == 1)
                        self.localBundle = app
                        self.lastUpdateTime = Date()
                        self.isVideoActive = true
                        
                        // Only reset manual pause if video state actually changed
                        if play == 1 && self.isManuallyPaused {
                            // Video is playing in browser, but we have manual pause
                            // Keep manual pause state
                        } else if play == 0 {
                            // Video is paused in browser, reset manual pause
                            self.isManuallyPaused = false
                        }
                        
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
                
                // Update elapsed time only if playing and not manually paused
                let now = Date()
                let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)
                
                if localIsPlaying && !isManuallyPaused {
                    localElapsed += timeSinceLastUpdate
                    
                    // Don't exceed duration
                    if localElapsed > localDuration {
                        localElapsed = localDuration
                        localIsPlaying = false
                    }
                }
                // If manually paused, don't advance time - keep current elapsed time
                
                // Update public values
                lastElapsed = localElapsed
                lastDuration = localDuration
                // If manually paused, show as paused regardless of localIsPlaying
                lastIsPlaying = localIsPlaying && !isManuallyPaused
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
    
    private func startGlobalKeyMonitoring() {
        // Remove existing monitors
        stopGlobalKeyMonitoring()

        // Start multiple key monitoring methods for maximum reliability
        let systemMonitor = NSEvent.addGlobalMonitorForEvents(matching: .systemDefined) { [weak self] event in
            let mediaKeySubtype: Int32 = 8
            if event.subtype.rawValue == mediaKeySubtype {

                let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
                let keyFlags = (event.data1 & 0x0000FFFF)
                let isKeyDown = ((keyFlags & 0xFF00) >> 8) == 0xA

                // Play/Pause key code is 16
                let playPauseKeyCode: Int32 = 16

                if isKeyDown && keyCode == playPauseKeyCode {
                    NSLog("BrowserVideoProbe: Media Play/Pause key pressed (keyCode: %d)", keyCode)
                    self?.toggleManualPause()
                }
            }
        }

        let regularMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // F8 key (keyCode 100) - most common media key
            let isF8 = event.keyCode == 100

            // Cmd+P combination
            let isCmdP = event.modifierFlags.contains(.command) && event.characters?.lowercased() == "p"

            // Option+P combination (alternative)
            let isOptionP = event.modifierFlags.contains(.option) && event.characters?.lowercased() == "p"

            // Trigger on any of these
            if isF8 || isCmdP || isOptionP {
                let keyName = isF8 ? "F8" : (isCmdP ? "Cmd+P" : "Option+P")
                NSLog("BrowserVideoProbe: %s key pressed (keyCode: %d)", keyName, event.keyCode)
                self?.toggleManualPause()
            }
        }

        // Store both monitors
        if let systemMonitor = systemMonitor {
            globalKeyMonitors.append(systemMonitor)
        }
        if let regularMonitor = regularMonitor {
            globalKeyMonitors.append(regularMonitor)
        }

        NSLog("BrowserVideoProbe: Started %d key monitors", globalKeyMonitors.count)
    }

    private func stopGlobalKeyMonitoring() {
        // Remove all existing monitors
        for monitor in globalKeyMonitors {
            NSEvent.removeMonitor(monitor)
        }
        globalKeyMonitors.removeAll()
    }
    
    private func toggleManualPause() {
        // Only toggle if video is active
        guard isVideoActive else { return }
        
        isManuallyPaused.toggle()
        
        NSLog("BrowserVideoProbe: manual pause toggled - isManuallyPaused: %@", isManuallyPaused ? "true" : "false")
        
        // Don't change localIsPlaying - let the normal video state handling work
        // Just use isManuallyPaused flag to control time advancement
        
        // Send notification to update UI
        sendNotification()
    }
}