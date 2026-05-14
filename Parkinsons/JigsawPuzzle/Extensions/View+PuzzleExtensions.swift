
import SwiftUI


extension View {

    func puzzleCard(cornerRadius: CGFloat = PuzzleTheme.radiusM) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(PuzzleTheme.cardBackground)
                    .shadow(
                        color: PuzzleTheme.shadow,
                        radius: PuzzleTheme.shadowRadius,
                        x: 0, y: PuzzleTheme.shadowY
                    )
            )
    }

    func puzzlePrimaryButton(color: Color = PuzzleTheme.accent) -> some View {
        self
            .font(PuzzleTheme.buttonLabel())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: PuzzleTheme.radiusL, style: .continuous)
                    .fill(color)
                    .shadow(color: color.opacity(0.35), radius: 8, x: 0, y: 4)
            )
    }

    func puzzleSecondaryButton(color: Color = PuzzleTheme.accent) -> some View {
        self
            .font(PuzzleTheme.headline())
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: PuzzleTheme.radiusL, style: .continuous)
                    .strokeBorder(color, lineWidth: 2)
            )
    }

    func puzzleIconButton(size: CGFloat = 48) -> some View {
        self
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(PuzzleTheme.cardBackground)
                    .shadow(color: PuzzleTheme.shadow, radius: 8, x: 0, y: 2)
            )
    }

    func correctPlacementGlow(isActive: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: PuzzleConstants.pieceCornerRadius)
                .strokeBorder(
                    isActive ? PuzzleTheme.success : Color.clear,
                    lineWidth: PuzzleConstants.correctPlacementBorderWidth
                )
                .animation(.easeInOut(duration: 0.3), value: isActive)
        )
    }

    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}


private struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 2)
                        .offset(x: phase * geo.size.width * 2)
                    }
                    .clipped()
                    .allowsHitTesting(false)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}


extension TimeInterval {
    var mmss: String {
        let total = Int(self)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
