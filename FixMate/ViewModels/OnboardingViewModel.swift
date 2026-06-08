import Foundation
import SwiftUI

@Observable
class OnboardingViewModel {
    var selectedHomeType: HomeType = .singleFamily
    var notificationEnabled = false
    var isOnboardingComplete = false

    private let dataController = DataController.shared

    func completeOnboarding() {
        let presetTasks = PresetTaskDatabase.shared.tasksForHomeType(selectedHomeType)
        for preset in presetTasks {
            let task = dataController.createTask(from: preset)
            if !preset.isFree {
                task.isFree = false
            }
            NotificationService.scheduleNotifications(for: task)
        }
        dataController.save()
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        UserDefaults.standard.set(selectedHomeType.rawValue, forKey: "homeType")
        isOnboardingComplete = true
    }

    func requestNotifications() async {
        notificationEnabled = await NotificationService.requestPermission()
    }
}
