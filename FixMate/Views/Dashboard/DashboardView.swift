import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var selectedTask: MaintenanceTask?
    @State private var showCompletionSheet = false
    @State private var showTaskDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    healthScoreSection
                    urgencySummaryBar
                    taskListSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("FixMate")
            .onAppear { viewModel.loadTasks() }
            .overlay {
                if viewModel.showCompletionAnimation {
                    completionAnimation
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
                TaskDetailView(task: task) {
                    selectedTask = task
                    showCompletionSheet = true
                }
            }
        }
    }

    private var healthScoreSection: some View {
        VStack(spacing: 12) {
            HealthScoreRingView(score: viewModel.healthScore.value, level: viewModel.healthScore.level)
            Text(viewModel.healthScore.level.label)
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.urgencyColor(for: viewModel.healthScore.level))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var urgencySummaryBar: some View {
        HStack(spacing: 0) {
            SummaryPill(count: viewModel.healthScore.overdueCount, label: "Overdue", color: .overdue)
            SummaryPill(count: viewModel.healthScore.dueSoonCount, label: "Due Soon", color: .dueSoon)
            SummaryPill(count: viewModel.healthScore.onTrackCount, label: "On Track", color: .onTrack)
        }
        .padding(8)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var taskListSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.sortedTasks(), id: \.id) { task in
                TaskCardView(
                    task: task,
                    onComplete: {
                        selectedTask = task
                        showCompletionSheet = true
                    },
                    onSnooze: { days in
                        viewModel.snoozeTask(task, days: days)
                    },
                    onTap: {
                        selectedTask = task
                        showTaskDetail = true
                    }
                )
            }
        }
    }

    private var completionAnimation: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.appAccent)
            Text(viewModel.completedTaskName)
                .font(.headline)
            if viewModel.scoreIncrement > 0 {
                Text("+\(viewModel.scoreIncrement) pts")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appAccent)
            }
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { viewModel.showCompletionAnimation = false }
            }
        }
    }
}

struct SummaryPill: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title3)
                .bold()
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
