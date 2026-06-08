import SwiftUI
import WidgetKit
import CoreData

@main
struct FixMateApp: App {
    @State private var dataController = DataController.shared
    @State private var hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")
    @State private var isLocked = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasOnboarded {
                    WelcomeView()
                        .onDisappear { hasOnboarded = true }
                } else {
                    mainContent
                }
            }
            .environment(\.managedObjectContext, dataController.viewContext)
            .overlay {
                if isLocked {
                    BiometricLockView(isLocked: $isLocked)
                }
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: "biometricLockEnabled") && BiometricService.isAvailable {
                    isLocked = true
                }
            }
        }
    }

    private var mainContent: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "list.checklist")
                }
            SeasonView()
                .tabItem {
                    Label("Seasons", systemImage: "leaf.fill")
                }
            ReportView()
                .tabItem {
                    Label("Report", systemImage: "chart.bar.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

struct BiometricLockView: View {
    @Binding var isLocked: Bool

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.appPrimary)
                Text("FixMate is Locked")
                    .font(.title2)
                    .bold()
                Text("Authenticate to access your data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    Task {
                        if await BiometricService.authenticate() {
                            withAnimation { isLocked = false }
                        }
                    }
                } label: {
                    Text("Unlock with \(BiometricService.biometricType)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
