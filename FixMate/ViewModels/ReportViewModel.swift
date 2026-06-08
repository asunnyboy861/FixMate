import Foundation

@Observable
class ReportViewModel {
    var selectedYear: Int = Calendar.current.component(.year, from: Date())
    var logs: [CompletionLog] = []
    var tasks: [MaintenanceTask] = []

    private let dataController = DataController.shared

    func loadData() {
        tasks = dataController.fetchAllTasks()
        logs = dataController.fetchCompletionLogs(forYear: selectedYear)
    }

    var totalSpent: Decimal {
        logs.compactMap { $0.cost as Decimal? }.reduce(0, +)
    }

    var totalCompletions: Int {
        logs.count
    }

    var estimatedSavings: Decimal {
        Decimal(totalCompletions) * 150
    }

    var monthlySpending: [(month: String, amount: Decimal)] {
        let calendar = Calendar.current
        let monthNames = DateFormatter().monthSymbols ?? []
        var result: [(month: String, amount: Decimal)] = []

        for (index, monthName) in monthNames.enumerated() {
            let monthLogs = logs.filter { log in
                let components = calendar.dateComponents([.month], from: log.completionDate ?? Date())
                return components.month == index + 1
            }
            let total = monthLogs.compactMap { $0.cost as Decimal? }.reduce(0, +)
            result.append((month: monthName, amount: total))
        }
        return result
    }

    var zoneBreakdown: [(zone: String, count: Int, cost: Decimal)] {
        var zoneMap: [String: (count: Int, cost: Decimal)] = [:]
        for log in logs {
            let task = tasks.first { $0.id == log.taskId }
            let zone = task?.zone ?? "General"
            let existing = zoneMap[zone] ?? (count: 0, cost: 0)
            zoneMap[zone] = (count: existing.count + 1, cost: existing.cost + (log.cost as Decimal? ?? 0))
        }
        return zoneMap.map { (zone: $0.key, count: $0.value.count, cost: $0.value.cost) }
            .sorted { $0.cost > $1.cost }
    }

    var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 5)...currentYear).reversed()
    }
}
