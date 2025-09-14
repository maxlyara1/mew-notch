//
//  NotchManager.swift
//  MewNotch
//
//  Created by Monu Kumar on 12/03/25.
//

import SwiftUI

class NotchManager: ObservableObject {

    static let shared = NotchManager()

    var notchDefaults: NotchDefaults = .shared

    var windows: [NSScreen: NSWindow] = [:]

    @Published var isScreenLocked: Bool = false
    private var unlockTimer: Timer?
    private var isRefreshing: Bool = false
    
    private init() {
        addListenerForScreenUpdates()
    }
    
    deinit {
        removeListenerForScreenUpdates()
    }
    
    @objc func refreshNotches(
        killAllWindows: Bool = false
    ) {
        
        let shownOnDisplays = Set(notchDefaults.shownOnDisplay.filter { $1 }.keys)
        
        let shouldShowOnScreen: (NSScreen) -> Bool = { [weak self] screen in
            guard let self else { return false }
            
            if self.notchDefaults.notchDisplayVisibility != .Custom {
                return true
            }
            
            return shownOnDisplays.contains(screen.localizedName)
        }
        
        windows.forEach { screen, window in
            if killAllWindows || !NSScreen.screens.contains(
                where: { $0 == screen}
            ) || !shouldShowOnScreen(screen) {
                window.close()
                
                windows.removeValue(
                    forKey: screen
                )
            }
        }
        
        NSScreen.screens.filter {
            shouldShowOnScreen($0)
        }.forEach { screen in
            var panel: NSWindow! = windows[screen]
            
            if panel == nil {
                let view: NSView = NSHostingView(
                    rootView: NotchView(
                        screen: screen
                    )
                )
                
                panel = MewPanel(
                    contentRect: .zero,
                    styleMask: [
                        .borderless,
                        .nonactivatingPanel
                    ],
                    backing: .buffered,
                    defer: true
                )
                
                panel.contentView = view
            }
            
            panel.setFrame(
                screen.frame,
                display: true
            )
            
            panel.orderFrontRegardless()
            
            windows[screen] = panel
            
            if notchDefaults.shownOnLockScreen {
                WindowManager.shared?.moveToLockScreen(panel)
            } else {
                NotchSpaceManager.shared.notchSpace.windows.insert(panel)
            }
        }
    }
    
    func addListenerForScreenUpdates() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshNotches),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // Listen for multiple screen lock/unlock events for reliability
        let lockEvents = [
            "com.apple.screensaver.didstart",
            "com.apple.screenIsLocked",
            "com.apple.loginwindow.UserAuthenticationLocked"
        ]

        let unlockEvents = [
            "com.apple.screensaver.didstop",
            "com.apple.screenIsUnlocked",
            "com.apple.loginwindow.UserAuthenticationUnlocked"
        ]

        lockEvents.forEach { event in
            DistributedNotificationCenter.default.addObserver(
                self,
                selector: #selector(screenDidLock),
                name: NSNotification.Name(event),
                object: nil
            )
        }

        unlockEvents.forEach { event in
            DistributedNotificationCenter.default.addObserver(
                self,
                selector: #selector(screenDidUnlock),
                name: NSNotification.Name(event),
                object: nil
            )
        }

        // Additional system event listeners
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screenDidUnlock),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screenDidLock),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
    }
    
    func removeListenerForScreenUpdates() {
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)

        // Clean up timers
        unlockTimer?.invalidate()
        unlockTimer = nil
    }

    @objc func screenDidLock() {
        DispatchQueue.main.async {
            self.isScreenLocked = true

            // Cancel any pending unlock operations
            self.unlockTimer?.invalidate()
            self.isRefreshing = false

            if !self.notchDefaults.shownOnLockScreen {
                self.hideAllNotches()
            }
        }
    }

    @objc func screenDidUnlock() {
        DispatchQueue.main.async {
            self.isScreenLocked = false

            // Cancel any existing unlock timer
            self.unlockTimer?.invalidate()

            // Progressive delay system for TouchID unlock
            self.scheduleUnlockRefresh()
        }
    }

    private func scheduleUnlockRefresh() {
        // Start with longer delay for TouchID stability
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            DispatchQueue.main.async {
                self.safeRefreshNotches()
            }
        }
    }

    private func safeRefreshNotches() {
        // Prevent concurrent refresh operations
        guard !isRefreshing else { return }

        isRefreshing = true

        // Check if screens are properly initialized
        guard !NSScreen.screens.isEmpty else {
            // Retry after screen initialization
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isRefreshing = false
                self.safeRefreshNotches()
            }
            return
        }

        // Perform refresh
        self.refreshNotches()

        isRefreshing = false
    }

    func hideAllNotches() {
        windows.values.forEach { window in
            window.orderOut(nil)
        }
    }

    func showAllNotches() {
        windows.values.forEach { window in
            window.orderFrontRegardless()
        }
    }

    // Emergency reset method
    func forceReset() {
        isRefreshing = false
        unlockTimer?.invalidate()
        unlockTimer = nil

        // Close all windows and recreate
        windows.values.forEach { $0.close() }
        windows.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshNotches()
        }
    }
}
