//
//  NeuroFlowDefaults.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import Foundation

class NeuroFlowDefaults: ObservableObject {
    
    private static var PREFIX: String = "NeuroFlow_"
    
    static let shared = NeuroFlowDefaults()
    
    private init() {}
    
    @PrimitiveUserDefault(
        PREFIX + "Enabled",
        defaultValue: true
    )
    var isEnabled: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        PREFIX + "FocusMinutes",
        defaultValue: 10
    )
    var focusMinutes: Int {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        PREFIX + "BreakSeconds",
        defaultValue: 10
    )
    var breakSeconds: Int {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        PREFIX + "IdleResetSeconds",
        defaultValue: 60
    )
    var idleResetSeconds: Int {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        PREFIX + "DimScreenDuringBreak",
        defaultValue: false
    )
    var dimScreenDuringBreak: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        PREFIX + "DimOpacity",
        defaultValue: 0.25
    )
    var dimOpacity: Double {
        didSet {
            self.objectWillChange.send()
        }
    }

    @CodableUserDefault(
        PREFIX + "AccentColor",
        defaultValue: NeuroFlowAccentColor.default
    )
    var accentColor: NeuroFlowAccentColor {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        PREFIX + "GlowIntensity",
        defaultValue: 1.5
    )
    var glowIntensity: Double {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        PREFIX + "BreathPeriod",
        defaultValue: 5.0
    )
    var breathPeriod: Double {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        PREFIX + "PlayBreakSound",
        defaultValue: true
    )
    var playBreakSound: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        PREFIX + "PauseMediaDuringBreak",
        defaultValue: true
    )
    var pauseMediaDuringBreak: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        PREFIX + "ResumeMediaAfterBreak",
        defaultValue: true
    )
    var resumeMediaAfterBreak: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
}
