import Foundation

struct HealthScore {
    let value: Int
    let level: UrgencyLevel
    let overdueCount: Int
    let dueSoonCount: Int
    let onTrackCount: Int

    var colorName: String { level.colorName }

    static func calculate(tasks: [MaintenanceTaskData]) -> HealthScore {
        guard !tasks.isEmpty else {
            return HealthScore(value: 100, level: .onTrack, overdueCount: 0, dueSoonCount: 0, onTrackCount: 0)
        }

        var overdueCount = 0
        var dueSoonCount = 0
        var onTrackCount = 0
        var totalScore: Double = 0
        var totalWeight: Double = 0

        for task in tasks {
            let daysOverdue = task.daysOverdue
            let frequencyWeight = max(1.0, Double(task.frequencyDays) / 90.0)

            let taskScore: Double
            if daysOverdue <= 0 {
                taskScore = 100.0
                onTrackCount += 1
            } else if daysOverdue <= 7 {
                taskScore = max(0, 80.0 - Double(daysOverdue) * 5.0)
                dueSoonCount += 1
            } else if daysOverdue <= 30 {
                taskScore = max(0, 50.0 - Double(daysOverdue - 7) * 1.5)
                overdueCount += 1
            } else {
                taskScore = max(0, 15.0 - Double(daysOverdue - 30) * 0.3)
                overdueCount += 1
            }

            totalScore += taskScore * frequencyWeight
            totalWeight += frequencyWeight
        }

        let value = totalWeight > 0 ? Int(totalScore / totalWeight) : 100
        let level: UrgencyLevel
        if value >= 80 { level = .onTrack }
        else if value >= 50 { level = .dueSoon }
        else if value >= 25 { level = .overdue }
        else { level = .critical }

        return HealthScore(value: value, level: level, overdueCount: overdueCount, dueSoonCount: dueSoonCount, onTrackCount: onTrackCount)
    }
}
