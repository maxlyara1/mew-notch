import SwiftUI

struct DynamicIslandHUDView: View {
    @ObservedObject var notchViewModel: NotchViewModel
    var hudModel: HUDPropertyModel?

    private func timeString(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }

    var body: some View {
        let width = notchViewModel.notchSize.width
        let height = notchViewModel.notchSize.height
        let sideWidth = max(88.0, width * 0.2)

        HStack {
            // Left capsule (app)
            HStack(spacing: 8) {
                Image(nsImage: BundleAppNameProvider.currentAppIcon())
                    .resizable()
                    .frame(width: 18, height: 18)
                Text(BundleAppNameProvider.currentAppName())
                    .font(.caption2.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule().stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
            .frame(width: sideWidth, alignment: .leading)
            
            Spacer()
            
            // Right capsule (remaining)
            Group {
                let e2 = BrowserVideoProbe.shared.lastElapsed
                let d2 = BrowserVideoProbe.shared.lastDuration
                let remain = (d2.isFinite && e2.isFinite && d2 > e2) ? (d2 - e2) : .nan
                Text(timeString(remain))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule().stroke(.white.opacity(0.08), lineWidth: 0.5)
                    )
                    .frame(width: sideWidth, alignment: .trailing)
            }
        }
        .padding(.horizontal, notchViewModel.extraNotchPadSize.width / 2)
        .frame(
            width: width,
            height: height
        )
        .allowsHitTesting(false)
        .transition(.opacity)
    }
}
