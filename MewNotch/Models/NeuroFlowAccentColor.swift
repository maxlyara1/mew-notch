//
//  NeuroFlowAccentColor.swift
//  MewNotch
//
//  Created by OpenAI Codex on 06/02/2026.
//

import AppKit
import SwiftUI

struct NeuroFlowAccentColor: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    static let `default` = NeuroFlowAccentColor(red: 0.12, green: 0.58, blue: 0.72, alpha: 1.0)

    static let presets: [NeuroFlowAccentColor] = [
        NeuroFlowAccentColor(red: 0.12, green: 0.58, blue: 0.72, alpha: 1.0), // ocean
        NeuroFlowAccentColor(red: 0.16, green: 0.72, blue: 0.92, alpha: 1.0), // sky
        NeuroFlowAccentColor(red: 0.26, green: 0.88, blue: 0.62, alpha: 1.0), // mint
        NeuroFlowAccentColor(red: 0.98, green: 0.73, blue: 0.24, alpha: 1.0), // amber
        NeuroFlowAccentColor(red: 1.0, green: 0.47, blue: 0.62, alpha: 1.0),  // pink
        NeuroFlowAccentColor(red: 0.62, green: 0.38, blue: 0.98, alpha: 1.0), // violet
        NeuroFlowAccentColor(red: 0.36, green: 0.74, blue: 1.0, alpha: 1.0),  // electric blue
        NeuroFlowAccentColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)  // soft white
    ]

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(color: Color) {
        let nsColor = NSColor(color)
        let rgb = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        self.red = Self.clamp(Double(rgb.redComponent))
        self.green = Self.clamp(Double(rgb.greenComponent))
        self.blue = Self.clamp(Double(rgb.blueComponent))
        self.alpha = Self.clamp(Double(rgb.alphaComponent))
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    func isClose(to other: NeuroFlowAccentColor, tolerance: Double = 0.02) -> Bool {
        abs(red - other.red) <= tolerance
        && abs(green - other.green) <= tolerance
        && abs(blue - other.blue) <= tolerance
        && abs(alpha - other.alpha) <= tolerance
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
