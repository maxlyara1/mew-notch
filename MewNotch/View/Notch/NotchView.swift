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

                    ExpandedNotchView(
                        namespace: namespace,
                        notchViewModel: notchViewModel,
                        collapsedNotchView: collapsedNotchView
                    )

                    collapsedNotchView
                }
                .background {
                    Color.black
                }
                .mask {
                    NotchShape(
                        topRadius: notchViewModel.cornerRadius.top,
                        bottomRadius: notchViewModel.cornerRadius.bottom
                    )
                }
                .scaleEffect(
                    notchViewModel.isHovered ? 1.05 : 1.0,
                    anchor: .top
                )
                .shadow(
                    color: notchViewModel.isHovered ? .black.opacity(0.4) : .clear,
                    radius: notchViewModel.isHovered ? 16 : 0,
                    x: 0,
                    y: notchViewModel.isHovered ? 6 : 0
                )
                .animation(
                    .spring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.2),
                    value: notchViewModel.isHovered
                )
                .onHover {
                    notchViewModel.onHover(
                        $0,
                        shouldExpand: true
                    )
                }
                .onTapGesture(
                    perform: notchViewModel.onTap
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
        notchManager.isScreenLocked && !notchDefaults.shownOnLockScreen
    }
}
