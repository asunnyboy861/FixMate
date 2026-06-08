import Foundation

struct MaintenanceTaskData: Identifiable {
    let id: UUID
    var name: String
    var zone: MaintenanceZone
    var frequencyDays: Int
    var seasonMask: UInt8
    var priority: Int
    var lastCompleted: Date?
    var nextDueDate: Date
    var isActive: Bool
    var isPreset: Bool
    var notes: String?

    var daysOverdue: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: nextDueDate)
        return calendar.dateComponents([.day], from: due, to: now).day ?? 0
    }

    var urgencyLevel: UrgencyLevel {
        let days = daysOverdue
        if days <= 0 { return .onTrack }
        if days <= 7 { return .dueSoon }
        if days <= 30 { return .overdue }
        return .critical
    }

    var daysUntilDue: Int {
        -daysOverdue
    }

    var lastCompletedAgo: String? {
        guard let last = lastCompleted else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: last), to: Calendar.current.startOfDay(for: Date())).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "1 day ago" }
        return "\(days) days ago"
    }
}

struct CompletionLogData: Identifiable {
    let id: UUID
    let taskId: UUID
    let completionDate: Date
    var notes: String?
    var cost: Decimal?
    var photoData: Data?
}

struct PresetTask: Identifiable {
    let id = UUID()
    let name: String
    let zone: MaintenanceZone
    let frequencyDays: Int
    let seasonMask: UInt8
    let priority: Int
    let homeTypes: [HomeType]
    let isFree: Bool
}
