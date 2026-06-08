import SwiftUI

struct TaskCardView: View {
    let task: MaintenanceTask
    let onComplete: () -> Void
    let onSnooze: (Int) -> Void
    let onTap: () -> Void

    var urgencyLevel: UrgencyLevel {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: task.nextDueDate ?? Date())).day ?? 0
        if days > 7 { return .onTrack }
        if days > 0 { return .dueSoon }
        if days > -30 { return .overdue }
        return .critical
    }

    var daysText: String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: task.nextDueDate ?? Date())).day ?? 0
        if days > 0 { return "Due in \(days)d" }
        if days == 0 { return "Due today" }
        return "\(abs(days))d overdue"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.urgencyColor(for: urgencyLevel))
                    .frame(width: 4, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name ?? "")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        Label(daysText, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(Color.urgencyColor(for: urgencyLevel))
                        if let lastCompleted = task.lastCompleted {
                            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastCompleted), to: Calendar.current.startOfDay(for: Date())).day ?? 0
                            Text("Done \(days)d ago")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Menu {
                    Button {
                        onComplete()
                    } label: {
                        Label("Mark Done", systemImage: "checkmark.circle")
                    }
                    Button { onSnooze(1) } label: {
                        Label("Snooze 1 Day", systemImage: "clock.arrow.circlepath")
                    }
                    Button { onSnooze(3) } label: {
                        Label("Snooze 3 Days", systemImage: "clock.arrow.circlepath")
                    }
                    Button { onSnooze(7) } label: {
                        Label("Snooze 1 Week", systemImage: "clock.arrow.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}
