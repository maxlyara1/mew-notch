//
//  DimmingOverlayManager.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import SwiftUI
import Combine

final class DimmingOverlayManager {
    
    static let shared = DimmingOverlayManager()
    
    private var windows: [NSScreen: NSWindow] = [:]
    private var cancellables: Set<AnyCancellable> = []
    private var isVisible: Bool = false
    private var isBreakActive: Bool = false
    
    private init() {}
    
    func start() {
        guard cancellables.isEmpty else { return }

        // Dimming is disabled by design for a clean UX.
        NeuroFlowDefaults.shared.dimScreenDuringBreak = false
        
        NeuroFlowManager.shared.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.isBreakActive = (state == .break)
                self?.refreshVisibility()
            }
            .store(in: &cancellables)

        NeuroFlowDefaults.shared.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshVisibility()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshScreens),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        
        NotchManager.shared.$isScreenLocked
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlays()
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self)
        setVisible(false)
    }
    
    @objc private func refreshScreens() {
        refreshOverlays()
    }
    
    private func setVisible(_ visible: Bool) {
        isVisible = visible
        refreshOverlays()
    }

    private func refreshVisibility() {
        setVisible(false)
    }
    
    private func refreshOverlays() {
        let shouldShow = isVisible && !NotchManager.shared.isScreenLocked
        
        var screensToRemove: [NSScreen] = []
        
        windows.forEach { screen, window in
            if !NSScreen.screens.contains(screen) {
                window.close()
                screensToRemove.append(screen)
                return
            }
            if !shouldShow {
                window.orderOut(nil)
            }
        }
        
        screensToRemove.forEach { screen in
            windows.removeValue(forKey: screen)
        }
        
        guard shouldShow else { return }
        
        NSScreen.screens.forEach { screen in
            var window = windows[screen]
            if window == nil {
                let view = NSHostingView(
                    rootView: NeuroFlowDimmingView()
                )
                
                let panel = NeuroFlowOverlayPanel(
                    contentRect: screen.frame,
                    backing: .buffered,
                    defer: true
                )
                
                panel.contentView = view
                window = panel
                windows[screen] = panel
            }
            
            window?.setFrame(screen.frame, display: true)
            window?.orderFrontRegardless()
        }
    }
}

final class NeuroFlowOverlayPanel: NSPanel {
    
    override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask = [.borderless, .nonactivatingPanel],
        backing: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: backing,
            defer: flag
        )
        
        isFloatingPanel = true
        isOpaque = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        isMovable = false
        ignoresMouseEvents = true
        hasShadow = false
        
        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle,
        ]
        
        level = .init(
            rawValue: .init(Int32.max - 3)
        )
    }
    
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
