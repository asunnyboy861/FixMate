import SwiftUI

struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeKit = StoreKitService.shared
    @State private var purchaseSucceeded = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 20)

                    Image(systemName: "house.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appPrimary)

                    Text("FixMate Pro")
                        .font(.largeTitle)
                        .bold()

                    Text("One purchase. All features. Forever.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    featureList

                    purchaseButton

                    restoreButton

                    legalLinks
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            FeatureRow(icon: "list.bullet.clipboard", text: "Unlimited maintenance tasks")
            FeatureRow(icon: "leaf.fill", text: "Seasonal dashboard")
            FeatureRow(icon: "camera.fill", text: "Photo records")
            FeatureRow(icon: "dollarsign.circle.fill", text: "Cost tracking & annual report")
            FeatureRow(icon: "square.and.arrow.up", text: "CSV/PDF export")
            FeatureRow(icon: "icloud.fill", text: "iCloud private sync")
            FeatureRow(icon: "plus.circle.fill", text: "Custom tasks & zones")
            FeatureRow(icon: "sparkles", text: "All future updates")
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var purchaseButton: some View {
        Button {
            Task {
                if await storeKit.purchase() {
                    purchaseSucceeded = true
                    dismiss()
                }
            }
        } label: {
            HStack {
                if storeKit.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Unlock Pro — $2.99")
                        .font(.headline)
                        .bold()
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(storeKit.isLoading)
    }

    private var restoreButton: some View {
        Button {
            Task { await storeKit.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/FixMate/privacy.html")!)
                .font(.caption2)
                .foregroundStyle(Color.appPrimary)
            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/FixMate/terms.html")!)
                .font(.caption2)
                .foregroundStyle(Color.appPrimary)
        }
        .padding(.top, 4)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(Color.appAccent)
        }
    }
}
