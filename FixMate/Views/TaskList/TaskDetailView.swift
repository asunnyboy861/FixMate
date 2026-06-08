import SwiftUI

struct TaskDetailView: View {
    let task: MaintenanceTask
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var logs: [CompletionLog] = []

    var isPro: Bool { StoreKitService.shared.isPro }

    var urgencyLevel: UrgencyLevel {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: task.nextDueDate ?? Date())).day ?? 0
        if days > 7 { return .onTrack }
        if days > 0 { return .dueSoon }
        if days > -30 { return .overdue }
        return .critical
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    detailsCard
                    if !logs.isEmpty { completionHistoryCard }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle(task.name ?? "Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onComplete() }
                        .bold()
                        .foregroundStyle(Color.appAccent)
                }
            }
            .onAppear {
                logs = DataController.shared.fetchCompletionLogs(for: task.id ?? UUID())
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            UrgencyBadge(level: urgencyLevel)
            if let dueDate = task.nextDueDate {
                Text(dueDate, style: .date)
                    .font(.title3)
                    .bold()
            }
            if let lastCompleted = task.lastCompleted {
                let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastCompleted), to: Calendar.current.startOfDay(for: Date())).day ?? 0
                Text("Last done \(days) days ago")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailRow(icon: MaintenanceZone(rawValue: task.zone ?? "General")?.icon ?? "wrench.fill", label: "Zone", value: task.zone ?? "General")
            DetailRow(icon: "clock.arrow.circlepath", label: "Frequency", value: "Every \(task.frequencyDays) days")
            DetailRow(icon: "flag.fill", label: "Priority", value: task.priority == 1 ? "High" : task.priority == 2 ? "Medium" : "Low")
            if let notes = task.notes, !notes.isEmpty {
                DetailRow(icon: "note.text", label: "Notes", value: notes)
            }
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var completionHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion History")
                .font(.headline)

            ForEach(logs, id: \.id) { log in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(log.completionDate ?? Date(), style: .date)
                            .font(.subheadline)
                        if let notes = log.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    if let cost = log.cost, cost.intValue > 0 {
                        Text("$\(cost.stringValue)")
                            .font(.subheadline)
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                .padding(.vertical, 4)

                if log.id != logs.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
        .font(.subheadline)
    }
}
