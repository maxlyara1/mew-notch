//
//  MewAppDelegate.swift
//  MewNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import SwiftUI

class MewAppDelegate: NSObject, NSApplicationDelegate {
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.openSettings) var openSettingsWindow
    
    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return false
    }
    
    func applicationWillTerminate(
        _ notification: Notification
    ) {
        // Ensure proper cleanup even in force quit scenarios
        NotchManager.shared.removeListenerForScreenUpdates()
        OSDUIManager.shared.start()
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidFinishLaunching(
        _ notification: Notification
    ) {
        if AppDefaults.shared.disableSystemHUD {
            OSDUIManager.shared.stop()
        }

        // Need to Initialise once to set system listeners
        AudioInput.sharedInstance()
        AudioOutput.sharedInstance()
        Brightness.sharedInstance()
        PowerStatus.sharedInstance()
        NowPlaying.sharedInstance()
        BrowserVideoProbe.shared.start()

        NotchManager.shared.refreshNotches()

        // Change from .accessory to .prohibited to make app visible in Activity Monitor
        // while still keeping it out of Dock and Cmd+Tab
        NSApp.setActivationPolicy(.prohibited)

        // Add emergency exit hotkey (Cmd+Shift+Option+Q)
        setupEmergencyExitHotkey()
    }

    private func setupEmergencyExitHotkey() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let commandPressed = event.modifierFlags.contains(.command)
            let shiftPressed = event.modifierFlags.contains(.shift)
            let optionPressed = event.modifierFlags.contains(.option)

            if commandPressed && shiftPressed && optionPressed && event.charactersIgnoringModifiers == "q" {
                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows: Bool
    ) -> Bool {
        if !hasVisibleWindows {
            openSettingsWindow.callAsFunction()
        }
        
        return !hasVisibleWindows
    }
    
    func applicationShouldTerminate(
        _ sender: NSApplication
    ) -> NSApplication.TerminateReply {
        // Clean up resources before termination
        NotchManager.shared.removeListenerForScreenUpdates()
        OSDUIManager.shared.start()

        return .terminateNow
    }

}
