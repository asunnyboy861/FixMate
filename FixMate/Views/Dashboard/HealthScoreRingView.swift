import SwiftUI

struct HealthScoreRingView: View {
    let score: Int
    let level: UrgencyLevel
    let size: CGFloat

    init(score: Int, level: UrgencyLevel, size: CGFloat = 160) {
        self.score = score
        self.level = level
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 12)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(Color.urgencyColor(for: level), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: score)

            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.urgencyColor(for: level))
                Text("Health Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}
