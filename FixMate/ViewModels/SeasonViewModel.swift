import Foundation

@Observable
class SeasonViewModel {
    var selectedSeason: Season = .current
    var tasks: [MaintenanceTask] = []

    private let dataController = DataController.shared

    func loadTasks() {
        tasks = dataController.fetchAllTasks().filter { $0.isActive }
    }

    func tasksForSeason(_ season: Season) -> [MaintenanceTask] {
        tasks.filter { task in
            let mask = UInt8(task.seasonMask)
            return mask & season.rawValue != 0 || mask == 0xF
        }
    }

    func taskCount(for season: Season) -> Int {
        tasksForSeason(season).count
    }

    var currentSeasonTasks: [MaintenanceTask] {
        tasksForSeason(selectedSeason)
    }
}
