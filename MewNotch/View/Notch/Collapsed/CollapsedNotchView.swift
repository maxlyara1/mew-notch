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
            // Left side HUDs (constrained to safeLeftWidth)
            HStack(spacing: 4) {
                // Video HUD (closest to notch)
                VideoHUDLeftView(
                    notchViewModel: notchViewModel,
                    hudModel: collapsedNotchViewModel.videoHUD
                )
                
                // Standard HUDs
                IslandHUDLeftView(
                    notchViewModel: notchViewModel,
                    defaults: HUDBrightnessDefaults.shared,
                    hudModel: collapsedNotchViewModel.brightnessHUD
                )
                IslandHUDLeftView(
                    notchViewModel: notchViewModel,
                    defaults: HUDAudioInputDefaults.shared,
                    hudModel: collapsedNotchViewModel.inputAudioVolumeHUD
                )
                IslandHUDLeftView(
                    notchViewModel: notchViewModel,
                    defaults: HUDAudioOutputDefaults.shared,
                    hudModel: collapsedNotchViewModel.outputAudioVolumeHUD
                )
            }

            OnlyNotchView(
                notchSize: notchViewModel.notchSize
            )

            // Right side HUDs (constrained to safeRightWidth)
            HStack(spacing: 4) {
                // Video HUD (closest to notch)
                VideoHUDRightView(
                    notchViewModel: notchViewModel,
                    hudModel: collapsedNotchViewModel.videoHUD
                )

                // Standard HUDs
                IslandHUDRightView(
                    notchViewModel: notchViewModel,
                    defaults: HUDAudioOutputDefaults.shared,
                    hudModel: collapsedNotchViewModel.outputAudioVolumeHUD
                )
                IslandHUDRightView(
                    notchViewModel: notchViewModel,
                    defaults: HUDAudioInputDefaults.shared,
                    hudModel: collapsedNotchViewModel.inputAudioVolumeHUD
                )
                IslandHUDRightView(
                    notchViewModel: notchViewModel,
                    defaults: HUDBrightnessDefaults.shared,
                    hudModel: collapsedNotchViewModel.brightnessHUD
                )
            }
        }
        .onReceive(notchDefaults.objectWillChange) {
            notchViewModel.refreshNotchSize()
        }
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1),
            value: notchViewModel.notchSize
        )
    }
}
