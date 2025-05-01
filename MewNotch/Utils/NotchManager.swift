//
//  NotchManager.swift
//  MewNotch
//
//  Created by Monu Kumar on 12/03/25.
//

import SwiftUI

class NotchManager {
    
    static let shared = NotchManager()
    
    var notchDefaults: NotchDefaults = .shared
    
    var windows: [NSScreen: NSWindow] = [:]
    
    private init() {
        addListenerForScreenUpdates()
    }
    
    deinit {
        removeListenerForScreenUpdates()
    }
    
    @objc func refreshNotches() {
        
        let shownOnDisplays = Set(notchDefaults.shownOnDisplay.filter { $1 }.keys)
        
        let shouldShowOnScreen: (NSScreen) -> Bool = { [weak self] screen in
            guard let self else { return false }
            
            if self.notchDefaults.notchDisplayVisibility != .Custom {
                return true
            }
            
            return shownOnDisplays.contains(screen.localizedName)
        }
        
        windows.forEach { screen, window in
            if !NSScreen.screens.contains(
                where: { $0 == screen}
            ) || !shouldShowOnScreen(screen) {
                window.close()
                
                NotchSpaceManager.shared.notchSpace.windows
                    .remove(
                        window
                    )
                
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
                
                panel.orderFrontRegardless()
                
                NotchSpaceManager.shared.notchSpace.windows.insert(panel)
            }
            
            panel.setFrame(
                screen.frame,
                display: true
            )
            
            self.windows[screen] = panel
        }
    }
    
    func addListenerForScreenUpdates() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshNotches),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    func removeListenerForScreenUpdates() {
        NotificationCenter.default.removeObserver(self)
    }
}
