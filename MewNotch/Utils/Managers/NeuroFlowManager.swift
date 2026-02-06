//
//  NeuroFlowManager.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import AppKit

final class NeuroFlowManager: ObservableObject {
    
    static let shared = NeuroFlowManager()
    
    enum State {
        case focus
        case `break`
    }
    
    @Published private(set) var state: State = .focus
    @Published private(set) var focusElapsed: TimeInterval = 0
    @Published private(set) var breakRemaining: TimeInterval = 0
    @Published private(set) var isEnabled: Bool = true
    
    private var timer: Timer?
    private var lastTick: Date = .now
    private var activeBreakDuration: TimeInterval = 0
    private let breakSoundNames: [NSSound.Name] = [
        NSSound.Name("Purr"),
        NSSound.Name("Glass"),
        NSSound.Name("Submarine"),
        NSSound.Name("Ping")
    ]
    private let breakEndSoundNames: [NSSound.Name] = [
        NSSound.Name("Tink"),
        NSSound.Name("Pop"),
        NSSound.Name("Hero"),
        NSSound.Name("Glass")
    ]
    
    private let activityEventTypes: [CGEventType] = [
        .keyDown,
        .leftMouseDown,
        .rightMouseDown,
        .otherMouseDown,
        .mouseMoved,
        .scrollWheel
    ]
    
    private init() {
        start()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    var isBreakActive: Bool {
        state == .break
    }
    
    var focusProgress: Double {
        let target = focusTargetSeconds
        guard target > 0 else { return 0 }
        return min(1, max(0, focusElapsed / target))
    }
    
    var breakProgress: Double {
        guard activeBreakDuration > 0 else { return 0 }
        return min(1, max(0, breakRemaining / activeBreakDuration))
    }
    
    func start() {
        timer?.invalidate()
        lastTick = .now
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func skipBreak() {
        guard state == .break else { return }
        endBreak()
    }
    
    func startBreakNow() {
        guard isEnabled else { return }
        startBreak(duration: breakTargetSeconds)
    }
    
    private var focusTargetSeconds: TimeInterval {
        let minutes = max(1, NeuroFlowDefaults.shared.focusMinutes)
        return TimeInterval(minutes * 60)
    }
    
    private var breakTargetSeconds: TimeInterval {
        let seconds = max(5, NeuroFlowDefaults.shared.breakSeconds)
        return TimeInterval(seconds)
    }
    
    private var idleResetSeconds: TimeInterval {
        let seconds = max(15, NeuroFlowDefaults.shared.idleResetSeconds)
        return TimeInterval(seconds)
    }
    
    private func tick() {
        let defaults = NeuroFlowDefaults.shared
        isEnabled = defaults.isEnabled
        
        guard isEnabled else {
            resetAll()
            return
        }
        
        let now = Date()
        let delta = now.timeIntervalSince(lastTick)
        lastTick = now
        
        if state == .focus {
            let idleSeconds = secondsSinceLastInput()
            if idleSeconds >= idleResetSeconds {
                focusElapsed = 0
            } else {
                focusElapsed = min(focusTargetSeconds, focusElapsed + delta)
            }
            
            if focusElapsed >= focusTargetSeconds {
                startBreak(duration: breakTargetSeconds)
            }
        } else {
            breakRemaining = max(0, breakRemaining - delta)
            if breakRemaining <= 0 {
                endBreak()
            }
        }
    }
    
    private func startBreak(duration: TimeInterval) {
        guard duration > 0 else {
            endBreak()
            return
        }
        
        state = .break
        activeBreakDuration = duration
        breakRemaining = duration
        focusElapsed = 0
        playBreakSoundIfNeeded()
    }
    
    private func endBreak() {
        let wasBreak = (state == .break)
        state = .focus
        breakRemaining = 0
        activeBreakDuration = 0
        focusElapsed = 0
        if wasBreak {
            playBreakEndSoundIfNeeded()
        }
    }
    
    private func resetAll() {
        state = .focus
        focusElapsed = 0
        breakRemaining = 0
        activeBreakDuration = 0
    }

    private func playBreakSoundIfNeeded() {
        guard NeuroFlowDefaults.shared.playBreakSound else { return }
        for name in breakSoundNames {
            if let sound = NSSound(named: name) {
                sound.volume = 0.6
                sound.play()
                return
            }
        }
        NSSound.beep()
    }

    private func playBreakEndSoundIfNeeded() {
        guard NeuroFlowDefaults.shared.playBreakSound else { return }
        for name in breakEndSoundNames {
            if let sound = NSSound(named: name) {
                sound.volume = 0.55
                sound.play()
                return
            }
        }
        NSSound.beep()
    }
    
    private func secondsSinceLastInput() -> TimeInterval {
        activityEventTypes
            .map { CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0) }
            .min() ?? .greatestFiniteMagnitude
    }
}
