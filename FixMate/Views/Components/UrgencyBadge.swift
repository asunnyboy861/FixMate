import SwiftUI

struct UrgencyBadge: View {
    let level: UrgencyLevel

    var body: some View {
        Text(level.label)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(Color.urgencyColor(for: level))
            .clipShape(Capsule())
    }
}
