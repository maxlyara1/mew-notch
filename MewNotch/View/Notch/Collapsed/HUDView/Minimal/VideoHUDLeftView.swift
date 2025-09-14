//
//  VideoHUDLeftView.swift
//  MewNotch
//
//  Created by MewNotch Team on 15/09/25.
//

import SwiftUI

struct VideoHUDLeftView: View {
    @ObservedObject var notchViewModel: NotchViewModel
    var hudModel: HUDPropertyModel?
    @State private var isAnimating = false
    @State private var showContent = false

    var body: some View {
        if let _ = hudModel {
            HStack(spacing: 6) {
                Image(nsImage: BundleAppNameProvider.currentAppIcon())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                Text(BundleAppNameProvider.currentAppName())
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 80)
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : -20)
            }
            .padding(.horizontal, 8)
            .frame(height: notchViewModel.notchSize.height * 0.80)
            .padding(.vertical, notchViewModel.notchSize.height * 0.10)
            .background(
                Capsule()
                    .fill(.black.opacity(0.85))
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    )
                    .scaleEffect(isAnimating ? 1 : 0.3, anchor: .trailing)
            )
            .foregroundStyle(.white)
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0.2, anchor: .trailing)
                        .combined(with: .opacity)
                        .combined(with: .offset(x: 20)),
                    removal: .scale(scale: 0.2, anchor: .trailing)
                        .combined(with: .opacity)
                )
            )
            .padding(.trailing, 2)
            .zIndex(1)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isAnimating = true
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                    showContent = true
                }
            }
            .onDisappear {
                isAnimating = false
                showContent = false
            }
        }
    }
}
