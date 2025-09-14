//
//  MinimalHUDView.swift
//  MewNotch
//
//  Created by Monu Kumar on 05/06/25.
//

import SwiftUI

struct MinimalHUDView<Content: View>: View {
    
    enum Variant {
        case left
        case right
    }
    
    @ObservedObject var notchViewModel: NotchViewModel
    
    var variant: Variant
    
    var content: () -> Content
    
    var body: some View {
        let pad = notchViewModel.minimalHUDPadding
        let box = notchViewModel.notchSize.height
        let extra = notchViewModel.extraNotchPadSize.width / 2 + 6
        let isLeft = (variant == .left)
        
        return content()
            .padding(pad)
            .frame(width: box, height: box)
            .transition(
                .move(edge: isLeft ? .trailing : .leading)
                    .combined(with: .opacity)
            )
            .padding(
                .init(
                    top: 0,
                    leading: extra * (isLeft ? 1 : -1),
                    bottom: 0,
                    trailing: extra * (isLeft ? -1 : 1)
                )
            )
    }
}
