//
//  CollapsedNotchView.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

import Lottie

struct CollapsedNotchView: View {
    
    var namespace: Namespace.ID
    
    @ObservedObject var notchViewModel: NotchViewModel
    
    @ObservedObject var collapsedNotchViewModel: CollapsedNotchViewModel
    
    @StateObject var notchDefaults = NotchDefaults.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // Standard HUDs (outer left)
            MinimalHUDLeftView(
                notchViewModel: notchViewModel,
                defaults: HUDBrightnessDefaults.shared,
                hudModel: collapsedNotchViewModel.brightnessHUD
            )
            MinimalHUDLeftView(
                notchViewModel: notchViewModel,
                defaults: HUDAudioInputDefaults.shared,
                hudModel: collapsedNotchViewModel.inputAudioVolumeHUD
            )
            MinimalHUDLeftView(
                notchViewModel: notchViewModel,
                defaults: HUDAudioOutputDefaults.shared,
                hudModel: collapsedNotchViewModel.outputAudioVolumeHUD
            )

            // Video HUD (inner left - closer to notch)
            VideoHUDLeftView(
                notchViewModel: notchViewModel,
                hudModel: collapsedNotchViewModel.videoHUD
            )

            OnlyNotchView(
                notchSize: notchViewModel.notchSize
            )

            // Video HUD (inner right - closer to notch)
            VideoHUDRightView(
                notchViewModel: notchViewModel,
                hudModel: collapsedNotchViewModel.videoHUD
            )

            // Standard HUDs (outer right)
            MinimalHUDRightView(
                notchViewModel: notchViewModel,
                defaults: HUDAudioOutputDefaults.shared,
                hudModel: collapsedNotchViewModel.outputAudioVolumeHUD
            )
            MinimalHUDRightView(
                notchViewModel: notchViewModel,
                defaults: HUDAudioInputDefaults.shared,
                hudModel: collapsedNotchViewModel.inputAudioVolumeHUD
            )
            MinimalHUDRightView(
                notchViewModel: notchViewModel,
                defaults: HUDBrightnessDefaults.shared,
                hudModel: collapsedNotchViewModel.brightnessHUD
            )
        }
        .onReceive(notchDefaults.objectWillChange) {
            notchViewModel.refreshNotchSize()
        }
    }
}
