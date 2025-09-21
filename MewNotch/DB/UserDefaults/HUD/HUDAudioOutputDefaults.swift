//
//  HUDAudioOutputDefaults.swift
//  MewNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

class HUDAudioOutputDefaults: HUDDefaultsProtocol {
    
    internal static var PREFIX: String = "HUD_Audio_Output_"
    
    static let shared = HUDAudioOutputDefaults()
    
    private init() {}
    
    @PrimitiveUserDefault(
        PREFIX + "Enabled",
        defaultValue: true
    )
    var isEnabled: Bool {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
}
