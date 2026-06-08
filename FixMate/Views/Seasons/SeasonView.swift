import SwiftUI

struct SeasonView: View {
    @State private var viewModel = SeasonViewModel()
    @State private var selectedTask: MaintenanceTask?
    @State private var showCompletionSheet = false

    var isPro: Bool { StoreKitService.shared.isPro }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                seasonTabBar
                if isPro {
                    taskList
                } else {
                    proRequiredView
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Seasons")
            .onAppear { viewModel.loadTasks() }
            .sheet(isPresented: $showCompletionSheet) {
                if let task = selectedTask {
                    CompletionSheet(task: task) { notes, cost, photoData in
                        DataController.shared.completeTask(task, notes: notes, cost: cost, photoData: photoData)
                        NotificationService.rescheduleNotifications(for: task)
                        viewModel.loadTasks()
                        showCompletionSheet = false
                    }
                }
            }
        }
    }

    private var seasonTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([Season.spring, .summer, .fall, .winter], id: \.rawValue) { season in
                    SeasonTab(
                        season: season,
                        count: viewModel.taskCount(for: season),
                        isSelected: viewModel.selectedSeason == season
                    ) {
                        withAnimation { viewModel.selectedSeason = season }
                    }
                }
            }
            .padding()
        }
        .background(Color.appCard)
    }

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.currentSeasonTasks, id: \.id) { task in
                    TaskCardView(
                        task: task,
                        onComplete: {
                            selectedTask = task
                            showCompletionSheet = true
                        },
                        onSnooze: { days in
                            task.nextDueDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
                            DataController.shared.save()
                            NotificationService.rescheduleNotifications(for: task)
                            viewModel.loadTasks()
                        },
                        onTap: {
                            selectedTask = task
                        }
                    )
                }
            }
            .padding()
        }
    }

    private var proRequiredView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appPrimary)
            Text("Seasonal View")
                .font(.title2)
                .bold()
            Text("Upgrade to Pro to see tasks organized by season.")
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
    }
}

struct SeasonTab: View {
    let season: Season
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: season.icon)
                    .font(.title3)
                Text(season.displayName)
                    .font(.caption)
                    .bold()
                Text("\(count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 72)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? Color.appPrimary : .secondary)
            .background(isSelected ? Color.appPrimary.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
