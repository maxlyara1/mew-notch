//
//  NeuroFlowDimmingView.swift
//  MewNotch
//
//  Created by OpenAI Codex on 03/02/2026.
//

import SwiftUI

struct NeuroFlowDimmingView: View {
    
    @StateObject private var neuroFlow = NeuroFlowManager.shared
    @StateObject private var defaults = NeuroFlowDefaults.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(max(0.1, min(0.6, defaults.dimOpacity)))
                .ignoresSafeArea()
        }
        .opacity(neuroFlow.isBreakActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: neuroFlow.isBreakActive)
    }
    
}

#Preview {
    NeuroFlowDimmingView()
}
