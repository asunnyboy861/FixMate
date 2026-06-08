import Foundation
import SwiftUI

@Observable
class SettingsViewModel {
    var isPro: Bool = DataController.shared.isPro
    var biometricLockEnabled: Bool = UserDefaults.standard.bool(forKey: "biometricLockEnabled")
    var notificationAdvance7d: Bool = UserDefaults.standard.bool(forKey: "notifAdvance7d") != false
    var notificationAdvance1d: Bool = UserDefaults.standard.bool(forKey: "notifAdvance1d") != false
    var notificationAdvance0d: Bool = UserDefaults.standard.bool(forKey: "notifAdvance0d") != false
    var reminderTime: Date = {
        let timeString = UserDefaults.standard.string(forKey: "reminderTime") ?? "09:00"
        let parts = timeString.split(separator: ":").compactMap { Int($0) }
        var components = DateComponents()
        components.hour = parts.count > 0 ? parts[0] : 9
        components.minute = parts.count > 1 ? parts[1] : 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    var biometricType: String { BiometricService.biometricType }
    var isBiometricAvailable: Bool { BiometricService.isAvailable }

    func toggleBiometricLock() {
        biometricLockEnabled.toggle()
        UserDefaults.standard.set(biometricLockEnabled, forKey: "biometricLockEnabled")
    }

    func toggleNotification7d() {
        notificationAdvance7d.toggle()
        UserDefaults.standard.set(notificationAdvance7d, forKey: "notifAdvance7d")
    }

    func toggleNotification1d() {
        notificationAdvance1d.toggle()
        UserDefaults.standard.set(notificationAdvance1d, forKey: "notifAdvance1d")
    }

    func toggleNotification0d() {
        notificationAdvance0d.toggle()
        UserDefaults.standard.set(notificationAdvance0d, forKey: "notifAdvance0d")
    }

    func updateReminderTime(_ date: Date) {
        reminderTime = date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let timeString = "\(components.hour ?? 9):\(String(format: "%02d", components.minute ?? 0))"
        UserDefaults.standard.set(timeString, forKey: "reminderTime")
    }

    func restorePurchases() async {
        await StoreKitService.shared.restorePurchases()
        isPro = StoreKitService.shared.isPro
    }

    func exportData(format: String) -> URL? {
        let dataController = DataController.shared
        let tasks = dataController.fetchAllTasks()
        let allLogs = dataController.fetchCompletionLogs(forYear: Calendar.current.component(.year, from: Date()))

        if format == "CSV" {
            return ExportService.exportCSV(tasks: tasks, logs: allLogs)
        } else {
            guard let data = ExportService.exportPDF(tasks: tasks, logs: allLogs) else { return nil }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("FixMate_Export.pdf")
            try? data.write(to: url)
            return url
        }
    }
}
