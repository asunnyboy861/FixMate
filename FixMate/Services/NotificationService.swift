import Foundation
import UserNotifications

struct NotificationService {
    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleNotifications(for task: MaintenanceTask) {
        guard task.isActive else { return }
        let content = UNMutableNotificationContent()
        content.title = "FixMate Reminder"
        content.body = "\(task.name ?? "Task") is due!"
        content.sound = .default
        content.userInfo = ["taskId": task.id?.uuidString ?? ""]

        let advanceDays: [Int] = [7, 1, 0]
        for (index, daysBefore) in advanceDays.enumerated() {
            guard let dueDate = task.nextDueDate else { continue }
            let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: dueDate) ?? dueDate
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(task.id?.uuidString ?? "")_\(index)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    static func rescheduleNotifications(for task: MaintenanceTask) {
        cancelNotifications(for: task)
        scheduleNotifications(for: task)
    }

    static func cancelNotifications(for task: MaintenanceTask) {
        let id = task.id?.uuidString ?? ""
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "\(id)_0", "\(id)_1", "\(id)_2"
        ])
    }

    static func scheduleAllTasks(_ tasks: [MaintenanceTask]) {
        for task in tasks where task.isActive {
            scheduleNotifications(for: task)
        }
    }
}
