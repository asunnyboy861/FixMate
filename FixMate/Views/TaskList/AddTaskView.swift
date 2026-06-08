import SwiftUI

struct AddTaskView: View {
    let isPro: Bool
    let currentCount: Int
    let onAdd: (String, MaintenanceZone, Int, UInt8, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var zone: MaintenanceZone = .general
    @State private var frequencyDays = 90
    @State private var selectedSeasons: Set<Season> = Set(Season.allCases.filter { $0 != .allYear })
    @State private var priority = 3

    private var isAtFreeLimit: Bool { !isPro && currentCount >= 10 }

    var body: some View {
        NavigationStack {
            if isAtFreeLimit {
                proRequiredView
            } else {
                Form {
                    Section {
                        TextField("Task Name", text: $name)
                    }

                    Section {
                        Picker("Zone", selection: $zone) {
                            ForEach(MaintenanceZone.allCases) { z in
                                Label(z.rawValue, systemImage: z.icon).tag(z)
                            }
                        }

                        Picker("Frequency", selection: $frequencyDays) {
                            Text("Monthly (30d)").tag(30)
                            Text("Quarterly (90d)").tag(90)
                            Text("Semi-Annual (180d)").tag(180)
                            Text("Annual (365d)").tag(365)
                        }

                        Picker("Priority", selection: $priority) {
                            Text("High").tag(1)
                            Text("Medium").tag(2)
                            Text("Low").tag(3)
                        }
                    }

                    Section {
                        ForEach([Season.spring, .summer, .fall, .winter], id: \.rawValue) { season in
                            Toggle(season.displayName, isOn: Binding(
                                get: { selectedSeasons.contains(season) },
                                set: { on in
                                    if on { selectedSeasons.insert(season) }
                                    else { selectedSeasons.remove(season) }
                                }
                            ))
                        }
                    } header: {
                        Text("Active Seasons")
                    }
                }
                .navigationTitle("Add Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let mask = selectedSeasons.reduce(UInt8(0)) { $0 | $1.rawValue }
                            onAdd(name, zone, frequencyDays, mask == 0 ? 0xF : mask, priority)
                            dismiss()
                        }
                        .disabled(name.isEmpty)
                    }
                }
            }
        }
    }

    private var proRequiredView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appPrimary)
            Text("Free Limit Reached")
                .font(.title2)
                .bold()
            Text("You've used all 10 free tasks. Upgrade to Pro for unlimited tasks and more features.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink {
                ProPaywallView()
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
        }
        .navigationTitle("Add Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
