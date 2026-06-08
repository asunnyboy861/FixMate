import SwiftUI

struct WelcomeView: View {
    @State private var viewModel = OnboardingViewModel()
    @State private var step = 0

    var body: some View {
        VStack(spacing: 0) {
            if step == 0 {
                homeTypeSelection
            } else if step == 1 {
                notificationPermission
            } else {
                confirmationView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    private var homeTypeSelection: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "house.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appPrimary)
            Text("Welcome to FixMate")
                .font(.largeTitle)
                .bold()
            Text("Your home maintenance companion")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()

            VStack(spacing: 16) {
                Text("What type of home do you have?")
                    .font(.headline)
                ForEach(HomeType.allCases) { homeType in
                    Button {
                        viewModel.selectedHomeType = homeType
                        step = 1
                    } label: {
                        HStack {
                            Image(systemName: homeType.icon)
                                .font(.title2)
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 40)
                            Text(homeType.rawValue)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    }
                }
            }
            .padding(.horizontal)
            Spacer(minLength: 40)
        }
    }

    private var notificationPermission: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appPrimary)
            Text("Stay on Track")
                .font(.largeTitle)
                .bold()
            Text("Get reminders before tasks are due")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()

            VStack(spacing: 16) {
                Button {
                    Task {
                        await viewModel.requestNotifications()
                        step = 2
                    }
                } label: {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    step = 2
                } label: {
                    Text("Skip for Now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            Spacer(minLength: 40)
        }
    }

    private var confirmationView: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appAccent)
            Text("All Set!")
                .font(.largeTitle)
                .bold()
            Text("We'll load \(PresetTaskDatabase.shared.tasksForHomeType(viewModel.selectedHomeType).count) maintenance tasks for your \(viewModel.selectedHomeType.rawValue.lowercased())")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()

            Button {
                viewModel.completeOnboarding()
            } label: {
                Text("Start FixMate!")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            Spacer(minLength: 40)
        }
    }
}
