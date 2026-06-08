import Foundation

enum Season: UInt8, CaseIterable, Identifiable {
    case spring = 0x1
    case summer = 0x2
    case fall = 0x4
    case winter = 0x8
    case allYear = 0xF

    var id: UInt8 { rawValue }

    var displayName: String {
        switch self {
        case .spring: "Spring"
        case .summer: "Summer"
        case .fall: "Fall"
        case .winter: "Winter"
        case .allYear: "All Year"
        }
    }

    var icon: String {
        switch self {
        case .spring: "flower.fill"
        case .summer: "sun.max.fill"
        case .fall: "leaf.fill"
        case .winter: "snowflake"
        case .allYear: "calendar"
        }
    }

    static var current: Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .fall
        default: return .winter
        }
    }
}

enum UrgencyLevel: Int, Comparable {
    case onTrack = 0
    case dueSoon = 1
    case overdue = 2
    case critical = 3

    var colorName: String {
        switch self {
        case .onTrack: "OnTrack"
        case .dueSoon: "DueSoon"
        case .overdue: "Overdue"
        case .critical: "Critical"
        }
    }

    var label: String {
        switch self {
        case .onTrack: "On Track"
        case .dueSoon: "Due Soon"
        case .overdue: "Overdue"
        case .critical: "Critical"
        }
    }

    static func < (lhs: UrgencyLevel, rhs: UrgencyLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum MaintenanceZone: String, CaseIterable, Identifiable {
    case hvac = "HVAC"
    case plumbing = "Plumbing"
    case electrical = "Electrical"
    case exterior = "Exterior"
    case interior = "Interior"
    case safety = "Safety"
    case appliances = "Appliances"
    case general = "General"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .hvac: "fanblades.fill"
        case .plumbing: "drop.fill"
        case .electrical: "bolt.fill"
        case .exterior: "house.fill"
        case .interior: "door.left.hand.open"
        case .safety: "shield.checkered"
        case .appliances: "washer.fill"
        case .general: "wrench.and.screwdriver.fill"
        }
    }
}

enum HomeType: String, CaseIterable, Identifiable {
    case singleFamily = "Single Family"
    case condo = "Condo / Apartment"
    case townhouse = "Townhouse"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .singleFamily: "house.fill"
        case .condo: "building.2.fill"
        case .townhouse: "house.and.flag.fill"
        }
    }
}
