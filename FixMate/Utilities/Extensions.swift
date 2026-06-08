import SwiftUI

extension Date {
    var shortDateString: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var mediumDateString: String {
        formatted(date: .long, time: .omitted)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: self)).day ?? 0
    }
}

extension Color {
    static let appPrimary = Color(red: 1.0, green: 0.42, blue: 0.21)
    static let appSecondary = Color(red: 0.176, green: 0.204, blue: 0.212)
    static let appAccent = Color(red: 0.0, green: 0.722, blue: 0.58)
    static let appBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let appCard = Color.white

    static let onTrack = Color(red: 0.0, green: 0.722, blue: 0.58)
    static let dueSoon = Color(red: 0.992, green: 0.796, blue: 0.431)
    static let overdue = Color(red: 0.882, green: 0.439, blue: 0.333)
    static let critical = Color(red: 0.839, green: 0.188, blue: 0.192)

    static func urgencyColor(for level: UrgencyLevel) -> Color {
        switch level {
        case .onTrack: .onTrack
        case .dueSoon: .dueSoon
        case .overdue: .overdue
        case .critical: .critical
        }
    }
}
