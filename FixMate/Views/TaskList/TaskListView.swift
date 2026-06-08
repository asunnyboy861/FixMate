import SwiftUI

struct TaskListView: View {
    @State private var viewModel = TaskListViewModel()
    @State private var showAddTask = false
    @State private var selectedTask: MaintenanceTask?
    @State private var showCompletionSheet = false

    var isPro: Bool { StoreKitService.shared.isPro }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredTasks, id: \.id) { task in
                    TaskRow(task: task)
                        .onTapGesture { selectedTask = task }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                selectedTask = task
                                showCompletionSheet = true
                            } label: {
                                Label("Done", systemImage: "checkmark.circle")
                            }
                            .tint(.green)
                        }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if !isPro && viewModel.tasks.count >= 10 {
                            showAddTask = true
                        } else {
                            showAddTask = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { viewModel.loadTasks() }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(isPro: isPro, currentCount: viewModel.tasks.count) { name, zone, freq, season, priority in
                    viewModel.addCustomTask(name: name, zone: zone, frequencyDays: freq, seasonMask: season, priority: priority)
                }
            }
            .sheet(isPresented: $showCompletionSheet) {
                if let task = selectedTask {
                    CompletionSheet(task: task) { notes, cost, photoData in
                        viewModel.completeTask(task, notes: notes, cost: cost, photoData: photoData)
                        showCompletionSheet = false
                    }
                }
            }
            .sheet(item: $selectedTask) { task in
                if !showCompletionSheet {
                    TaskDetailView(task: task) {
                        selectedTask = task
                        showCompletionSheet = true
                    }
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: MaintenanceTask

    var urgencyLevel: UrgencyLevel {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: task.nextDueDate ?? Date())).day ?? 0
        if days > 7 { return .onTrack }
        if days > 0 { return .dueSoon }
        if days > -30 { return .overdue }
        return .critical
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.urgencyColor(for: urgencyLevel))
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name ?? "")
                    .font(.subheadline)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Image(systemName: MaintenanceZone(rawValue: task.zone ?? "General")?.icon ?? "wrench.fill")
                        .font(.caption2)
                    Text(task.zone ?? "General")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            UrgencyBadge(level: urgencyLevel)
        }
        .padding(.vertical, 4)
    }
}
