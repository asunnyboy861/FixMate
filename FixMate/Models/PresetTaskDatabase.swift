import Foundation

struct PresetTaskDatabase {
    static let shared = PresetTaskDatabase()

    let tasks: [PresetTask] = [
        PresetTask(name: "Change HVAC Filter", zone: .hvac, frequencyDays: 90, seasonMask: 0xF, priority: 1, homeTypes: [.singleFamily, .condo, .townhouse], isFree: true),
        PresetTask(name: "Test Smoke Detectors", zone: .safety, frequencyDays: 90, seasonMask: 0xF, priority: 1, homeTypes: [.singleFamily, .condo, .townhouse], isFree: true),
        PresetTask(name: "Clean Gutters", zone: .exterior, frequencyDays: 180, seasonMask: 0x4 | 0x8, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: true),
        PresetTask(name: "Flush Water Heater", zone: .plumbing, frequencyDays: 365, seasonMask: 0x2, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: true),
        PresetTask(name: "Check for Leaks", zone: .plumbing, frequencyDays: 90, seasonMask: 0xF, priority: 1, homeTypes: [.singleFamily, .condo, .townhouse], isFree: true),
        PresetTask(name: "Clean Dryer Vent", zone: .appliances, frequencyDays: 365, seasonMask: 0xF, priority: 1, homeTypes: [.singleFamily, .condo, .townhouse], isFree: true),
        PresetTask(name: "Test CO Detector", zone: .safety, frequencyDays: 90, seasonMask: 0xF, priority: 1, homeTypes: [.singleFamily, .condo, .townhouse], isFree: true),
        PresetTask(name: "Inspect Sump Pump", zone: .plumbing, frequencyDays: 180, seasonMask: 0x1 | 0x2, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: true),
        PresetTask(name: "Check Weatherstripping", zone: .exterior, frequencyDays: 365, seasonMask: 0x8, priority: 3, homeTypes: [.singleFamily, .townhouse], isFree: true),
        PresetTask(name: "Deep Clean Home", zone: .interior, frequencyDays: 90, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: true),
        PresetTask(name: "Service AC Unit", zone: .hvac, frequencyDays: 365, seasonMask: 0x1, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Inspect Roof", zone: .exterior, frequencyDays: 365, seasonMask: 0x1 | 0x2, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Clean Range Hood Filter", zone: .appliances, frequencyDays: 90, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Foundation Cracks", zone: .exterior, frequencyDays: 365, seasonMask: 0x1, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Test GFCI Outlets", zone: .electrical, frequencyDays: 90, seasonMask: 0xF, priority: 1, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Clean Garbage Disposal", zone: .plumbing, frequencyDays: 30, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Inspect Attic Ventilation", zone: .interior, frequencyDays: 365, seasonMask: 0x2, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Lubricate Garage Door", zone: .exterior, frequencyDays: 180, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Clean Refrigerator Coils", zone: .appliances, frequencyDays: 180, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Window Seals", zone: .exterior, frequencyDays: 365, seasonMask: 0x8, priority: 2, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Inspect Deck/Patio", zone: .exterior, frequencyDays: 365, seasonMask: 0x1, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Service Furnace", zone: .hvac, frequencyDays: 365, seasonMask: 0x8, priority: 1, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Clean Bathroom Exhaust Fan", zone: .interior, frequencyDays: 180, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Water Softener", zone: .plumbing, frequencyDays: 90, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Inspect Chimney", zone: .interior, frequencyDays: 365, seasonMask: 0x8, priority: 1, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Trim Trees Near House", zone: .exterior, frequencyDays: 365, seasonMask: 0x1, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Clean Light Fixtures", zone: .interior, frequencyDays: 180, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Door Locks", zone: .safety, frequencyDays: 365, seasonMask: 0xF, priority: 2, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Inspect Washing Machine Hoses", zone: .appliances, frequencyDays: 180, seasonMask: 0xF, priority: 2, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Clean Dishwasher Filter", zone: .appliances, frequencyDays: 60, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Fence Condition", zone: .exterior, frequencyDays: 365, seasonMask: 0x1, priority: 3, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Test Emergency Lights", zone: .safety, frequencyDays: 90, seasonMask: 0xF, priority: 2, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Inspect Crawlspace", zone: .interior, frequencyDays: 180, seasonMask: 0x1 | 0x2, priority: 2, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Clean Kitchen Exhaust", zone: .appliances, frequencyDays: 90, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Sprinkler System", zone: .exterior, frequencyDays: 180, seasonMask: 0x1 | 0x2, priority: 3, homeTypes: [.singleFamily, .townhouse], isFree: false),
        PresetTask(name: "Polish Wood Furniture", zone: .interior, frequencyDays: 90, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Inspect Electrical Panel", zone: .electrical, frequencyDays: 365, seasonMask: 0xF, priority: 2, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Clean Ceiling Fan Blades", zone: .interior, frequencyDays: 90, seasonMask: 0xF, priority: 3, homeTypes: [.singleFamily, .condo, .townhouse], isFree: false),
        PresetTask(name: "Check Pool Equipment", zone: .exterior, frequencyDays: 30, seasonMask: 0x2, priority: 2, homeTypes: [.singleFamily], isFree: false),
    ]

    func tasksForHomeType(_ homeType: HomeType) -> [PresetTask] {
        tasks.filter { $0.homeTypes.contains(homeType) }
    }

    func freeTasksForHomeType(_ homeType: HomeType) -> [PresetTask] {
        tasks.filter { $0.homeTypes.contains(homeType) && $0.isFree }
    }
}
