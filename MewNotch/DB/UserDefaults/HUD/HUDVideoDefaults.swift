//
//  HUDVideoDefaults.swift
//  MewNotch
//
//  Created by MewNotch Team on 14/09/25.
//

import SwiftUI

class HUDVideoDefaults: HUDDefaultsProtocol {
    internal static var PREFIX: String = "HUD_Video_"
    static let shared = HUDVideoDefaults()
    private init() {}

    @PrimitiveUserDefault(PREFIX + "Enabled", defaultValue: true)
    var isEnabled: Bool {
        didSet { withAnimation { self.objectWillChange.send() } }
    }


    @PrimitiveUserDefault(PREFIX + "ShowOnlyWhenVideo", defaultValue: true)
    var showOnlyWhenVideo: Bool {
        didSet { withAnimation { self.objectWillChange.send() } }
    }

    @PrimitiveUserDefault(PREFIX + "ChromiumOnly", defaultValue: false)
    var chromiumOnly: Bool {
        didSet { withAnimation { self.objectWillChange.send() } }
    }

    @PrimitiveUserDefault(PREFIX + "PersistentEdgeOverlay", defaultValue: false)
    var persistentEdgeOverlay: Bool {
        didSet { withAnimation { self.objectWillChange.send() } }
    }
}


