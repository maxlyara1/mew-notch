//
//  CollapsedNotchViewModel.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

import Lottie

class CollapsedNotchViewModel: ObservableObject {
    
    // Enum to identify HUD types
    private enum HUDType {
        case outputAudioVolume, inputAudioVolume, brightness, video, lockStatus,
             outputAudioDevice, inputAudioDevice, powerStatus
    }
    
    // Timer to manage HUD visibility
    private var activeHUDTimer: Timer?
    
    // Currently active HUD
    private var activeHUD: HUDType? {
        didSet {
            // Invalidate timer when active HUD changes
            activeHUDTimer?.invalidate()
        }
    }
    
    @Published var outputAudioVolumeHUD: HUDPropertyModel?
    @Published var outputAudioDeviceHUD: HUDPropertyModel?
    
    @Published var inputAudioVolumeHUD: HUDPropertyModel?
    @Published var inputAudioDeviceHUD: HUDPropertyModel?
    
    @Published var brightnessHUD: HUDPropertyModel?
    
    @Published var powerStatusHUD: HUDPropertyModel?
    
    @Published var lockStatusHUD: HUDPropertyModel?

    // Video HUD
    @Published var videoHUD: HUDPropertyModel?
    
    // Video HUD State
    private var videoProgressTimer: Timer?
    private var videoPlaybackState: VideoPlaybackState = .inactive
    private var videoElapsed: Double = 0
    private var videoDuration: Double = 0

    private enum VideoPlaybackState {
        case playing, paused, inactive
    }

    @Published var lastPowerStatus: String = ""
    @Published var lastBrightness: Float = 0.0
    private var lastUnlockTime: Date = Date.distantPast
    private var isInitialized: Bool = false
    private var originalBrightnessEnabled: Bool = true
    private var debounceTimer: Timer?
    private var hoverDebounceTimer: Timer?
    private var isProcessingUpdate: Bool = false
    
    init() {
        self.startListeners()
        // Mark as initialized after a short delay to prevent initial brightness display
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isInitialized = true
        }
    }
    
    deinit {
        self.stopListeners()
        debounceTimer?.invalidate()
        hoverDebounceTimer?.invalidate()
    }
    
    private func setActiveHUD(_ hudType: HUDType, model: HUDPropertyModel, timeout: TimeInterval?) {
        // Prevent overlapping updates
        guard !isProcessingUpdate else { return }

        // More aggressive debouncing for performance
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            self.isProcessingUpdate = true

            // Use background queue for heavy operations
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    // Don't hide other HUDs - allow multiple to be visible
                    self.activeHUD = hudType

                    // Simplified animation for better performance
                    withAnimation(.linear(duration: 0.15)) {
                        switch hudType {
                        case .outputAudioVolume: self.outputAudioVolumeHUD = model
                        case .inputAudioVolume: self.inputAudioVolumeHUD = model
                        case .brightness: self.brightnessHUD = model
                        case .video: self.videoHUD = model
                        case .lockStatus: self.lockStatusHUD = model
                        case .outputAudioDevice: self.outputAudioDeviceHUD = model
                        case .inputAudioDevice: self.inputAudioDeviceHUD = model
                        case .powerStatus: self.powerStatusHUD = model
                        }
                    }

                    if let timeout = timeout {
                        self.activeHUDTimer = .scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                            self?.hideSpecificHUD(hudType)
                        }
                    }

                    self.isProcessingUpdate = false
                }
            }
        }
    }
    
    private func hideSpecificHUD(_ hudType: HUDType) {
        guard !isProcessingUpdate else { return }

        withAnimation(.linear(duration: 0.1)) {
            switch hudType {
            case .outputAudioVolume: self.outputAudioVolumeHUD = nil
            case .inputAudioVolume: self.inputAudioVolumeHUD = nil
            case .brightness: self.brightnessHUD = nil
            case .video: self.videoHUD = nil
            case .lockStatus: self.lockStatusHUD = nil
            case .outputAudioDevice: self.outputAudioDeviceHUD = nil
            case .inputAudioDevice: self.inputAudioDeviceHUD = nil
            case .powerStatus: self.powerStatusHUD = nil
            }
        }
    }
    

    private func resetVideoState() {
        videoProgressTimer?.invalidate()
        videoProgressTimer = nil
        videoPlaybackState = .inactive
        videoElapsed = 0
        videoDuration = 0
        hideSpecificHUD(.video)
    }
    
    func startListeners() {
        // MARK: Input Audio Change Listeners
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInputVolumeChanges),
            name: NSNotification.Name.AudioInputVolume,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInputDeviceChanges),
            name: NSNotification.Name.AudioInputDevice,
            object: nil
        )
        
        // MARK: Output Audio Change Listeners
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioOutputVolumeChanges),
            name: NSNotification.Name.AudioOutputVolume,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioOutputDeviceChanges),
            name: NSNotification.Name.AudioOutputDevice,
            object: nil
        )
        
        // MARK: Brightness Change Listener
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBrightnessChanges(_:)),
            name: NSNotification.Name.Brightness,
            object: nil
        )
        
        // MARK: Power Source Change Listener
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePowerStatusChanges),
            name: NSNotification.Name.PowerStatus,
            object: nil
        )
        
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenLocked),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenUnlocked),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )

        // Now Playing updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNowPlayingUpdates(_:)),
            name: NSNotification.Name.NowPlaying,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBrowserVideoProgress(_:)),
            name: NSNotification.Name.BrowserVideoProgress,
            object: nil
        )
    }
    
    @objc func screenLocked(notification: Notification) {
        let model = HUDPropertyModel(
            lottie: MewNotch.Lotties.brightness,
            icon: MewNotch.Assets.iconSpeaker,
            name: "Screen Locked",
            value: 1.0
        )
        setActiveHUD(.lockStatus, model: model, timeout: nil)
    }
    
    @objc func screenUnlocked(notification: Notification) {
        // Record unlock time to suppress brightness changes during unlock
        lastUnlockTime = Date()

        // Temporarily disable brightness HUD for 5 seconds
        originalBrightnessEnabled = HUDBrightnessDefaults.shared.isEnabled
        HUDBrightnessDefaults.shared.isEnabled = false

        // Re-enable brightness HUD after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            HUDBrightnessDefaults.shared.isEnabled = self.originalBrightnessEnabled
        }

        // Use background queue to prevent UI blocking
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                // Simply hide the lock status HUD without showing anything
                self.hideSpecificHUD(.lockStatus)
            }
        }
    }


    
    func stopListeners() {
        NotificationCenter.default.removeObserver(self)
        
        DistributedNotificationCenter.default().removeObserver(self)
    }

    @objc private func handleNowPlayingUpdates(_ notification: Notification) {
        // This can be simplified or removed if BrowserVideoProbe is primary
    }

    @objc private func handleBrowserVideoProgress(_ notification: Notification) {
        guard HUDVideoDefaults.shared.isEnabled else { resetVideoState(); return }
        guard let ui = notification.userInfo,
              let bundleId = ui["bundle"] as? String,
              let elapsed = ui["elapsed"] as? Double,
              let duration = ui["duration"] as? Double,
              let playing = ui["playing"] as? Bool else { return }

        // Aggressive debouncing for video updates to prevent lag on hover
        hoverDebounceTimer?.invalidate()
        hoverDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.processVideoUpdate(bundleId: bundleId, elapsed: elapsed, duration: duration, playing: playing)
        }
    }

    private func processVideoUpdate(bundleId: String, elapsed: Double, duration: Double, playing: Bool) {

        if HUDVideoDefaults.shared.chromiumOnly && !(bundleId.contains(".google.Chrome") || bundleId.lowercased().contains("yandex") || bundleId.lowercased().contains("chromium") || bundleId.lowercased().contains("comet")) {
            return
        }

        videoElapsed = elapsed
        videoDuration = duration

        if playing && duration > 1 {
            if videoPlaybackState != .playing {
                videoPlaybackState = .playing
                // Do not start a local timer - rely on BrowserVideoProbe updates
            }

            let progress = duration > 0 ? max(0, min(1, Float(elapsed / duration))) : 0
            let model = HUDPropertyModel(
                lottie: nil,
                icon: Image(nsImage: BundleAppNameProvider.currentAppIcon()),
                name: BundleAppNameProvider.currentAppName(),
                value: progress,
                elapsed: videoElapsed,
                duration: videoDuration
            )

            // Always update video HUD when video is playing
            withAnimation(.linear(duration: 0.1)) {
                self.videoHUD = model
            }

        } else {
            // Video is paused or stopped
            videoPlaybackState = .paused
            videoProgressTimer?.invalidate()
            videoProgressTimer = nil

            // Keep showing the HUD with current position when paused
            if duration > 1 && elapsed < duration {
                let progress = duration > 0 ? max(0, min(1, Float(elapsed / duration))) : 0
                let model = HUDPropertyModel(
                    lottie: nil,
                    icon: Image(nsImage: BundleAppNameProvider.currentAppIcon()),
                    name: BundleAppNameProvider.currentAppName(),
                    value: progress,
                    elapsed: videoElapsed,
                    duration: videoDuration
                )

                // Always update video HUD when paused
                withAnimation(.linear(duration: 0.1)) {
                    self.videoHUD = model
                }
            } else if elapsed >= duration || duration <= 1 {
                resetVideoState()
            }
        }
    }
    
    @objc private func handleAudioInputDeviceChanges() {
        if !HUDAudioInputDefaults.shared.isEnabled { return }
        let model = HUDPropertyModel(
            lottie: nil,
            icon: MewNotch.Assets.iconSpeaker,
            name: AudioInput.sharedInstance().deviceName ?? "",
            value: 0.0
        )
        setActiveHUD(.inputAudioDevice, model: model, timeout: 2.0)
    }
    
    @objc private func handleAudioInputVolumeChanges() {
        if !HUDAudioInputDefaults.shared.isEnabled { return }
        let model = HUDPropertyModel(
            lottie: nil,
            icon: .init(systemName: "microphone.fill"),
            name: "Input Volume",
            value: VolumeManager.shared.getInputVolume()
        )
        setActiveHUD(.inputAudioVolume, model: model, timeout: 2.0)
    }
    
    @objc private func handleAudioOutputDeviceChanges() {
        if !HUDAudioOutputDefaults.shared.isEnabled { return }
        let model = HUDPropertyModel(
            lottie: nil,
            icon: MewNotch.Assets.iconSpeaker,
            name: AudioOutput.sharedInstance().deviceName ?? "",
            value: 0.0
        )
        setActiveHUD(.outputAudioDevice, model: model, timeout: 2.0)
    }
    
    @objc private func handleAudioOutputVolumeChanges() {
        if !HUDAudioOutputDefaults.shared.isEnabled { return }
        let model = HUDPropertyModel(
            lottie: MewNotch.Lotties.speaker,
            icon: MewNotch.Assets.iconSpeaker,
            name: "Output Volume",
            value: VolumeManager.shared.getOutputVolume()
        )
        setActiveHUD(.outputAudioVolume, model: model, timeout: 2.0)
    }
    
    @objc private func handleBrightnessChanges(
        _ notification: NSNotification
    ) {
        if !HUDBrightnessDefaults.shared.isEnabled { return }

        // Don't show brightness during initialization
        if !isInitialized { return }

        // Suppress brightness display for 3 seconds after unlock to prevent unwanted display
        if Date().timeIntervalSince(lastUnlockTime) < 3.0 {
            return
        }

        var newBrightness: Float! = (notification.userInfo?["value"] as? Float)
        newBrightness = newBrightness ?? Brightness.sharedInstance().brightness

        defer { lastBrightness = newBrightness }

        if !HUDBrightnessDefaults.shared.showAutoBrightnessChanges && abs(lastBrightness - newBrightness) < 0.01 {
            if activeHUD == .brightness {
                self.brightnessHUD?.value = newBrightness
            }
            return
        }
        
        let model = HUDPropertyModel(
            lottie: MewNotch.Lotties.brightness,
            icon: MewNotch.Assets.iconBrightness,
            name: "Brightness",
            value: newBrightness
        )
        setActiveHUD(.brightness, model: model, timeout: 2.0)
    }
    
    @objc private func handlePowerStatusChanges() {
        if lastPowerStatus == PowerStatus.sharedInstance().providingSource() { return }
        
        self.lastPowerStatus = PowerStatus.sharedInstance().providingSource()
        let isCharging = PowerStatus.sharedInstance().providingSource() == PowerStatusACPower
        var batteryLevelForIcon = Int(PowerStatus.sharedInstance().getBatteryLevel() * 100)
        batteryLevelForIcon -= (batteryLevelForIcon % 25)
        
        let model = HUDPropertyModel(
            lottie: nil,
            icon: .init(systemName: isCharging ? "battery.100percent.bolt" : "battery.\(batteryLevelForIcon)percent"),
            name: PowerStatus.sharedInstance().providingSource(),
            value: Float(PowerStatus.sharedInstance().remainingTime()),
            timeout: PowerStatus.sharedInstance().remainingTime().isFinite ? 3.0 : 1.0
        )
        setActiveHUD(.powerStatus, model: model, timeout: model.timeout)
    }
}
