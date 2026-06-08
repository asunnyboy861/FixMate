import Foundation
import SwiftUI

@Observable
class TaskListViewModel {
    var tasks: [MaintenanceTask] = []
    var searchText = ""
    var selectedZone: MaintenanceZone?

    private let dataController = DataController.shared

    func loadTasks() {
        tasks = dataController.fetchAllTasks().filter { $0.isActive }
    }

    var filteredTasks: [MaintenanceTask] {
        var result = tasks
        if !searchText.isEmpty {
            result = result.filter { ($0.name ?? "").localizedCaseInsensitiveContains(searchText) }
        }
        if let zone = selectedZone {
            result = result.filter { $0.zone == zone.rawValue }
        }
        return result.sorted { task1, task2 in
            let days1 = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: task1.nextDueDate ?? Date())).day ?? 0
            let days2 = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: task2.nextDueDate ?? Date())).day ?? 0
            return days1 < days2
        }
    }

    func addCustomTask(name: String, zone: MaintenanceZone, frequencyDays: Int, seasonMask: UInt8, priority: Int) {
        let task = dataController.createCustomTask(name: name, zone: zone, frequencyDays: frequencyDays, seasonMask: seasonMask, priority: priority)
        NotificationService.scheduleNotifications(for: task)
        dataController.save()
        loadTasks()
    }

    func deleteTask(_ task: MaintenanceTask) {
        NotificationService.cancelNotifications(for: task)
        dataController.deleteTask(task)
        loadTasks()
    }

    func completeTask(_ task: MaintenanceTask, notes: String?, cost: Decimal?, photoData: Data?) {
        dataController.completeTask(task, notes: notes, cost: cost, photoData: photoData)
        NotificationService.rescheduleNotifications(for: task)
        loadTasks()
    }

    func snoozeTask(_ task: MaintenanceTask, days: Int) {
        task.nextDueDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
        dataController.save()
        NotificationService.rescheduleNotifications(for: task)
        loadTasks()
    }
}
