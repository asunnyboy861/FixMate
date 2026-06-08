import WidgetKit
import SwiftUI
import CoreData

struct FixMateWidgetEntry: TimelineEntry {
    let date: Date
    let healthScore: Int
    let overdueCount: Int
    let dueSoonCount: Int
    let nextDueTask: String?
}

struct FixMateWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FixMateWidgetEntry {
        FixMateWidgetEntry(date: Date(), healthScore: 85, overdueCount: 2, dueSoonCount: 3, nextDueTask: "Change HVAC Filter")
    }

    func getSnapshot(in context: Context, completion: @escaping (FixMateWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FixMateWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadEntry() -> FixMateWidgetEntry {
        let container = NSPersistentContainer(name: "FixMate")
        if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zzoutuo.FixMate")?.appendingPathComponent("FixMate.sqlite") {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
        container.loadPersistentStores { _, _ in }

        let request = NSFetchRequest<MaintenanceTask>(entityName: "MaintenanceTask")
        request.predicate = NSPredicate(format: "isActive == YES")
        let tasks = (try? container.viewContext.fetch(request)) ?? []

        var overdue = 0
        var dueSoon = 0
        var nextDue: String?

        for task in tasks {
            guard let due = task.nextDueDate else { continue }
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
            if days < 0 { overdue += 1 }
            else if days <= 7 { dueSoon += 1 }
            if nextDue == nil {
                nextDue = task.name
            }
        }

        let score = tasks.isEmpty ? 100 : max(0, 100 - overdue * 15 - dueSoon * 5)

        return FixMateWidgetEntry(date: Date(), healthScore: score, overdueCount: overdue, dueSoonCount: dueSoon, nextDueTask: nextDue)
    }
}

struct FixMateWidgetSmall: View {
    let entry: FixMateWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(entry.healthScore) / 100.0)
                    .stroke(entry.healthScore >= 80 ? Color.green : entry.healthScore >= 50 ? Color.yellow : Color.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(entry.healthScore)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .frame(width: 50, height: 50)
            Text("FixMate")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct FixMateWidgetMedium: View {
    let entry: FixMateWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.healthScore) / 100.0)
                        .stroke(entry.healthScore >= 80 ? Color.green : entry.healthScore >= 50 ? Color.yellow : Color.red, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(entry.healthScore)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("FixMate")
                    .font(.caption)
                    .bold()
                if entry.overdueCount > 0 {
                    Text("\(entry.overdueCount) Overdue")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
                if entry.dueSoonCount > 0 {
                    Text("\(entry.dueSoonCount) Due Soon")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                if let next = entry.nextDueTask {
                    Text(next)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct FixMateWidgetLarge: View {
    let entry: FixMateWidgetEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("FixMate")
                    .font(.headline)
                Spacer()
                Text("Score: \(entry.healthScore)")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(entry.healthScore >= 80 ? .green : entry.healthScore >= 50 ? .yellow : .red)
            }

            HStack(spacing: 16) {
                VStack {
                    Text("\(entry.overdueCount)")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.red)
                    Text("Overdue")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(entry.dueSoonCount)")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.orange)
                    Text("Due Soon")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let next = entry.nextDueTask {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("Next: \(next)")
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                }
                .foregroundStyle(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct FixMateWidget: Widget {
    let kind: String = "FixMateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FixMateWidgetProvider()) { entry in
            FixMateWidgetSmall(entry: entry)
        }
        .configurationDisplayName("FixMate")
        .description("See your home health score at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct FixMateWidgetBundle: WidgetBundle {
    var body: some Widget {
        FixMateWidget()
    }
}
