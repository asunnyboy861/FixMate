import Foundation
import SwiftUI
import WidgetKit

@Observable
class DashboardViewModel {
    var healthScore: HealthScore = HealthScore(value: 100, level: .onTrack, overdueCount: 0, dueSoonCount: 0, onTrackCount: 0)
    var tasks: [MaintenanceTask] = []
    var showCompletionAnimation = false
    var completedTaskName = ""
    var scoreIncrement = 0

    private let dataController = DataController.shared

    func loadTasks() {
        tasks = dataController.fetchAllTasks().filter { $0.isActive }
        recalculateScore()
    }

    func recalculateScore() {
        let taskData = tasks.map { task in
            MaintenanceTaskData(
                id: task.id ?? UUID(),
                name: task.name ?? "",
                zone: MaintenanceZone(rawValue: task.zone ?? "General") ?? .general,
                frequencyDays: Int(task.frequencyDays),
                seasonMask: UInt8(task.seasonMask),
                priority: Int(task.priority),
                lastCompleted: task.lastCompleted,
                nextDueDate: task.nextDueDate ?? Date(),
                isActive: task.isActive,
                isPreset: task.isPreset,
                notes: task.notes
            )
        }
        healthScore = HealthScore.calculate(tasks: taskData)
    }

    func completeTask(_ task: MaintenanceTask, notes: String?, cost: Decimal?, photoData: Data?) {
        let oldScore = healthScore.value
        dataController.completeTask(task, notes: notes, cost: cost, photoData: photoData)
        NotificationService.rescheduleNotifications(for: task)
        WidgetCenter.shared.reloadAllTimelines()
        loadTasks()
        let newScore = healthScore.value
        scoreIncrement = newScore - oldScore
        completedTaskName = task.name ?? ""
        showCompletionAnimation = true
    }

    func snoozeTask(_ task: MaintenanceTask, days: Int) {
        task.nextDueDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
        dataController.save()
        NotificationService.rescheduleNotifications(for: task)
        loadTasks()
    }

    func deleteTask(_ task: MaintenanceTask) {
        NotificationService.cancelNotifications(for: task)
        dataController.deleteTask(task)
        loadTasks()
    }

    var overdueTasks: [MaintenanceTask] {
        tasks.filter { task in
            guard let due = task.nextDueDate else { return false }
            return Calendar.current.startOfDay(for: due) < Calendar.current.startOfDay(for: Date())
        }
    }

    var dueSoonTasks: [MaintenanceTask] {
        tasks.filter { task in
            guard let due = task.nextDueDate else { return false }
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
            return days >= 0 && days <= 7
        }
    }

    var onTrackTasks: [MaintenanceTask] {
        tasks.filter { task in
            guard let due = task.nextDueDate else { return false }
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
            return days > 7
        }
    }

    func sortedTasks() -> [MaintenanceTask] {
        overdueTasks + dueSoonTasks + onTrackTasks
    }
}
