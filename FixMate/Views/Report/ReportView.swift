import SwiftUI
import Charts

struct ReportView: View {
    @State private var viewModel = ReportViewModel()

    var isPro: Bool { StoreKitService.shared.isPro }

    var body: some View {
        NavigationStack {
            Group {
                if isPro {
                    reportContent
                } else {
                    proRequiredView
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Report")
            .onAppear { viewModel.loadData() }
        }
    }

    private var reportContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                yearPicker

                summaryCards

                monthlyChart

                zoneBreakdownCard
            }
            .padding()
        }
    }

    private var yearPicker: some View {
        Picker("Year", selection: $viewModel.selectedYear) {
            ForEach(viewModel.availableYears, id: \.self) { year in
                Text("\(year)").tag(year)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedYear) { _, _ in viewModel.loadData() }
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            SummaryCardView(title: "Completed", value: "\(viewModel.totalCompletions)", icon: "checkmark.circle.fill", color: .appAccent)
            SummaryCardView(title: "Total Spent", value: "$\(viewModel.totalSpent)", icon: "dollarsign.circle.fill", color: .appPrimary)
            SummaryCardView(title: "Est. Saved", value: "$\(viewModel.estimatedSavings)", icon: "shield.checkered", color: .onTrack)
        }
    }

    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Spending")
                .font(.headline)

            Chart(viewModel.monthlySpending, id: \.month) { item in
                BarMark(
                    x: .value("Month", String(item.month.prefix(3))),
                    y: .value("Amount", Double(truncating: item.amount as NSDecimalNumber))
                )
                .foregroundStyle(Color.appPrimary.gradient)
            }
            .frame(height: 200)
            .chartYAxisLabel("$")
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var zoneBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zone Breakdown")
                .font(.headline)

            ForEach(viewModel.zoneBreakdown, id: \.zone) { item in
                HStack {
                    Text(item.zone)
                        .font(.subheadline)
                    Spacer()
                    Text("\(item.count) tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(item.cost)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appPrimary)
                }
                Divider()
            }
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var proRequiredView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appPrimary)
            Text("Annual Report")
                .font(.title2)
                .bold()
            Text("Upgrade to Pro to see your yearly maintenance report with spending charts and zone breakdown.")
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

struct SummaryCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
