import CoreData
import Combine

class DataController: ObservableObject {
    static let shared = DataController()

    let container: NSPersistentContainer

    @Published var isPro: Bool = UserDefaults.standard.bool(forKey: "isPro")

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FixMate")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zzoutuo.FixMate")?
                .appendingPathComponent("FixMate.sqlite")
            if let storeURL = storeURL {
                let description = NSPersistentStoreDescription(url: storeURL)
                description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
                description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
                container.persistentStoreDescriptions = [description]
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }

    func createTask(from preset: PresetTask) -> MaintenanceTask {
        let task = MaintenanceTask(context: viewContext)
        task.id = UUID()
        task.name = preset.name
        task.zone = preset.zone.rawValue
        task.frequencyDays = Int16(preset.frequencyDays)
        task.seasonMask = Int16(preset.seasonMask)
        task.priority = Int16(preset.priority)
        task.lastCompleted = nil
        task.nextDueDate = Date()
        task.isActive = true
        task.isPreset = true
        task.isFree = preset.isFree
        task.notes = nil
        return task
    }

    func createCustomTask(name: String, zone: MaintenanceZone, frequencyDays: Int, seasonMask: UInt8, priority: Int) -> MaintenanceTask {
        let task = MaintenanceTask(context: viewContext)
        task.id = UUID()
        task.name = name
        task.zone = zone.rawValue
        task.frequencyDays = Int16(frequencyDays)
        task.seasonMask = Int16(seasonMask)
        task.priority = Int16(priority)
        task.lastCompleted = nil
        task.nextDueDate = Date()
        task.isActive = true
        task.isPreset = false
        task.isFree = false
        task.notes = nil
        return task
    }

    func completeTask(_ task: MaintenanceTask, notes: String?, cost: Decimal?, photoData: Data?) {
        let log = CompletionLog(context: viewContext)
        log.id = UUID()
        log.taskId = task.id
        log.completionDate = Date()
        log.notes = notes
        log.cost = cost as? NSDecimalNumber
        log.photoData = photoData

        task.lastCompleted = Date()
        task.nextDueDate = Calendar.current.date(byAdding: .day, value: Int(task.frequencyDays), to: Date())
        task.notes = notes

        save()
    }

    func deleteTask(_ task: MaintenanceTask) {
        viewContext.delete(task)
        save()
    }

    func fetchAllTasks() -> [MaintenanceTask] {
        let request: NSFetchRequest<MaintenanceTask> = MaintenanceTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MaintenanceTask.nextDueDate, ascending: true)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func fetchCompletionLogs(for taskId: UUID) -> [CompletionLog] {
        let request: NSFetchRequest<CompletionLog> = CompletionLog.fetchRequest()
        request.predicate = NSPredicate(format: "taskId == %@", taskId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CompletionLog.completionDate, ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func fetchCompletionLogs(forYear year: Int) -> [CompletionLog] {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1
        let startDate = calendar.date(from: startComponents)!

        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = 12
        endComponents.day = 31
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59
        let endDate = calendar.date(from: endComponents)!

        let request: NSFetchRequest<CompletionLog> = CompletionLog.fetchRequest()
        request.predicate = NSPredicate(format: "completionDate >= %@ AND completionDate <= %@", startDate as CVarArg, endDate as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CompletionLog.completionDate, ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func setPro(_ value: Bool) {
        isPro = value
        UserDefaults.standard.set(value, forKey: "isPro")
    }
}
