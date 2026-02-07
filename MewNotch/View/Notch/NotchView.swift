//
//  NotchView.swift
//  MewNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import SwiftUI

struct NotchView: View {
    
    @Namespace var namespace
    
    @Environment(\.openSettings) private var openSettings
    
    @StateObject var notchDefaults = NotchDefaults.shared

    @StateObject var notchManager = NotchManager.shared
    @StateObject var neuroFlow = NeuroFlowManager.shared

    @StateObject var notchViewModel: NotchViewModel
    @StateObject var collapsedNotchViewModel: CollapsedNotchViewModel = .init()
    
    @State var isExpanded: Bool = false
    
    init(
        screen: NSScreen
    ) {
        self._notchViewModel = .init(
            wrappedValue: .init(
                screen: screen
            )
        )
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Spacer()
                
                ZStack(
                    alignment: .top
                ) {
                    let collapsedNotchView = CollapsedNotchView(
                        namespace: namespace,
                        notchViewModel: notchViewModel,
                        collapsedNotchViewModel: collapsedNotchViewModel
                    )

                    ZStack {
                        ExpandedNotchView(
                            namespace: namespace,
                            notchViewModel: notchViewModel,
                            collapsedNotchView: collapsedNotchView
                        )

                        collapsedNotchView
                    }
                    .background {
                        if notchViewModel.isExpanded {
                            NotchShape(
                                topRadius: notchViewModel.cornerRadius.top,
                                bottomRadius: notchViewModel.cornerRadius.bottom
                            )
                            .fill(Color.black.opacity(0.88))
                        }
                    }
                    .mask {
                        NotchShape(
                            topRadius: notchViewModel.cornerRadius.top,
                            bottomRadius: notchViewModel.cornerRadius.bottom
                        )
                    }

                    NotchOutlineView(
                        notchViewModel: notchViewModel,
                        isHovered: notchViewModel.isHovered || neuroFlow.isBreakActive
                    )
                    .allowsHitTesting(false)

                    NeuroFlowNotchOverlayView(
                        neuroFlow: neuroFlow,
                        notchViewModel: notchViewModel
                    )
                    .allowsHitTesting(false)
                }
                .onHover {
                    notchViewModel.onHover(
                        $0,
                        shouldExpand: notchDefaults.expandOnHover
                    )
                }
                .onTapGesture(
                    perform: {
                        guard !neuroFlow.isBreakActive else { return }
                        notchViewModel.onTap()
                    }
                )
                
                Spacer()
            }
            
            Spacer()
        }
        .preferredColorScheme(.dark)
        .contextMenu {
            NotchOptionsView()
        }
        .opacity(shouldHideOnLock ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: shouldHideOnLock)
    }

    private var shouldHideOnLock: Bool {
        notchManager.isScreenLocked
    }
}
