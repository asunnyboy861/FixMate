import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var showPaywall = false
    @State private var showShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            Form {
                if !viewModel.isPro {
                    proSection
                }

                notificationSection

                if viewModel.isBiometricAvailable {
                    securitySection
                }

                exportSection

                legalSection

                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                ProPaywallView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private var proSection: some View {
        Section {
            Button {
                showPaywall = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(Color.appPrimary)
                    Text("Upgrade to Pro")
                        .foregroundStyle(Color.appPrimary)
                    Spacer()
                    Text("$2.99")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("7 Days Before", isOn: Binding(
                get: { viewModel.notificationAdvance7d },
                set: { _ in viewModel.toggleNotification7d() }
            ))
            Toggle("1 Day Before", isOn: Binding(
                get: { viewModel.notificationAdvance1d },
                set: { _ in viewModel.toggleNotification1d() }
            ))
            Toggle("On Due Date", isOn: Binding(
                get: { viewModel.notificationAdvance0d },
                set: { _ in viewModel.toggleNotification0d() }
            ))
            DatePicker("Reminder Time", selection: Binding(
                get: { viewModel.reminderTime },
                set: { viewModel.updateReminderTime($0) }
            ), displayedComponents: .hourAndMinute)
        } header: {
            Text("Notifications")
        }
    }

    private var securitySection: some View {
        Section {
            Toggle("\(viewModel.biometricType) Lock", isOn: Binding(
                get: { viewModel.biometricLockEnabled },
                set: { _ in viewModel.toggleBiometricLock() }
            ))
        } header: {
            Text("Security")
        }
    }

    private var exportSection: some View {
        Section {
            Button {
                if let url = viewModel.exportData(format: "CSV") {
                    exportURL = url
                    showShareSheet = true
                }
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Export as CSV")
                }
            }

            Button {
                if let url = viewModel.exportData(format: "PDF") {
                    exportURL = url
                    showShareSheet = true
                }
            } label: {
                HStack {
                    Image(systemName: "doc.richtext.fill")
                    Text("Export as PDF")
                }
            }
        } header: {
            Text("Data Export")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://asunnyboy861.github.io/FixMate/privacy.html")!) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/FixMate/terms.html")!) {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Terms of Use")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/FixMate/support.html")!) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Support")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
            NavigationLink {
                ContactSupportView()
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Contact Support")
                }
            }
            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                HStack {
                    Image(systemName: "arrow.uturn.down.circle.fill")
                    Text("Restore Purchases")
                }
            }
        } header: {
            Text("Legal & Support")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
