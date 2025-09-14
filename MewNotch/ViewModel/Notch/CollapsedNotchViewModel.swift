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
    
    init() {
        self.startListeners()
    }
    
    deinit {
        self.stopListeners()
    }
    
    private func setActiveHUD(_ hudType: HUDType, model: HUDPropertyModel, timeout: TimeInterval?) {
        hideAllHUDs(except: hudType)
        activeHUD = hudType
        
        withAnimation(.spring()) {
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
            activeHUDTimer = .scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                self?.hideActiveHUD()
            }
        }
    }
    
    private func hideActiveHUD() {
        if let activeHUD = activeHUD {
            withAnimation(.spring()) {
                switch activeHUD {
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
            self.activeHUD = nil
        }
    }
    
    private func hideAllHUDs(except: HUDType? = nil) {
        if activeHUD != except {
            hideActiveHUD()
        }
        if except != .outputAudioVolume { outputAudioVolumeHUD = nil }
        if except != .inputAudioVolume { inputAudioVolumeHUD = nil }
        if except != .brightness { brightnessHUD = nil }
        // Keep video HUD persistent while other HUDs are active if setting allows
        if except != .video {
            if !HUDVideoDefaults.shared.persistentEdgeOverlay {
                videoHUD = nil
            }
        }
        if except != .lockStatus { lockStatusHUD = nil }
        if except != .outputAudioDevice { outputAudioDeviceHUD = nil }
        if except != .inputAudioDevice { inputAudioDeviceHUD = nil }
        if except != .powerStatus { powerStatusHUD = nil }
    }

    private func resetVideoState() {
        videoProgressTimer?.invalidate()
        videoProgressTimer = nil
        videoPlaybackState = .inactive
        videoElapsed = 0
        videoDuration = 0
        if activeHUD == .video {
            hideActiveHUD()
        }
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
        if activeHUD == .lockStatus {
            self.lockStatusHUD?.value = 0.0
            setActiveHUD(.lockStatus, model: self.lockStatusHUD!, timeout: 1.0)
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

            if activeHUD != .video {
                setActiveHUD(.video, model: model, timeout: nil)
            } else {
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

                if activeHUD == .video {
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
