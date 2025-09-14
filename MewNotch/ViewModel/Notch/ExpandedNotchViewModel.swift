//
//  ExpandedNotchViewModel.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/03/25.
//

import SwiftUI

class ExpandedNotchViewModel: ObservableObject {

    init() {
        self.startListeners()
    }
    
    deinit {
        self.stopListeners()
    }
    
    func startListeners() {
    }
    
    func stopListeners() {
        NotificationCenter.default.removeObserver(self)
    }

}
