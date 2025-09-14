//
//  HUDPropertyModel.swift
//  MewNotch
//
//  Created by Monu Kumar on 11/03/25.
//

import SwiftUI

import Lottie

struct HUDPropertyModel {
    let lottie: LottieAnimation?
    let icon: Image
    
    var name: String
    var value: Float
    
    // For video HUD
    var elapsed: Double?
    var duration: Double?
    
    var timeout: TimeInterval = 1
    var timer: Timer? = nil
    
    @ViewBuilder
    func getIcon() -> some View {
        icon
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.white)
            .opacity(lottie == nil ? 1 : 0)
            .overlay {
                if let lottieAnimation = lottie {
                    LottieView(
                        animation: lottieAnimation
                    )
                    .currentProgress(CGFloat(value))
                    .configuration(
                        .init(
                            renderingEngine: .mainThread
                        )
                    )
                    .colorInvert()
                    .scaledToFit()
                }
            }
    }
}
