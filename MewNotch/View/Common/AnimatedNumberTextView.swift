//
//  AnimatedNumberTextView.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

struct AnimatedTextView<Content>: View where Content: View {
    
    var value: Double
    
    var content: (Double) -> Content
    
    private let epsilon: Double = 0.0001
    @State private var previousInt: Int? = nil
    
    var body: some View {
        let displayedInt = Int(floor(value + epsilon))
        let isIncreasing = (previousInt.map { displayedInt > $0 } ?? false)
        let isDecreasing = (previousInt.map { displayedInt < $0 } ?? false)
        let yOffset: CGFloat = isIncreasing ? -2 : (isDecreasing ? 2 : 0)
        let scale: CGFloat = (isIncreasing || isDecreasing) ? 1.06 : 1.0
        
        content(Double(displayedInt))
            // Изолируем от анимаций родителей
            .transaction { transaction in
                transaction.animation = nil
            }
            // Акуратная смена цифр и лёгкая микропластика
            .contentTransition(.numericText(value: Double(displayedInt)))
            .scaleEffect(scale)
            .offset(y: yOffset)
            .animation(
                .spring(
                    .smooth(
                        duration: 0.22,
                        extraBounce: 0.0
                    )
                ),
                value: displayedInt
            )
            .onAppear {
                previousInt = displayedInt
            }
            .onChange(of: displayedInt) { newValue in
                previousInt = newValue
            }
    }
}
