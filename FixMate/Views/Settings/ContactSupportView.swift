import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubject: SubjectOption = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    enum SubjectOption: String, CaseIterable {
        case general = "General"
        case featureSuggestion = "Feature Suggestion"
        case bugReport = "Bug Report"
        case usageQuestion = "Usage Question"
        case performanceIssue = "Performance Issue"
        case uiImprovement = "UI Improvement"
        case other = "Other"

        var icon: String {
            switch self {
            case .general: "message.fill"
            case .featureSuggestion: "lightbulb.fill"
            case .bugReport: "ladybug"
            case .usageQuestion: "questionmark.circle.fill"
            case .performanceIssue: "gauge.with.dots.needle.33percent"
            case .uiImprovement: "paintbrush.fill"
            case .other: "ellipsis.circle.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    subjectSection
                    if selectedSubject == .other {
                        customSubjectField
                    }
                    nameField
                    emailField
                    messageField
                    submitButton
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your feedback has been submitted successfully.")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subject")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(SubjectOption.allCases, id: \.self) { option in
                    Button {
                        selectedSubject = option
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: option.icon)
                                .font(.caption)
                            Text(option.rawValue)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedSubject == option ? .white : .primary)
                        .background(selectedSubject == option ? Color.appPrimary : Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedSubject == option ? Color.appPrimary : Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom Subject")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Enter your subject", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Message")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(4)
                .background(Color.appCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }

    private var submitButton: some View {
        Button {
            submitFeedback()
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                }
                Text("Submit Feedback")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(name.isEmpty || email.isEmpty || message.isEmpty ? Color.gray : Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(name.isEmpty || email.isEmpty || message.isEmpty || isSubmitting)
    }

    private func submitFeedback() {
        isSubmitting = true
        let subject = selectedSubject == .other ? customSubject : selectedSubject.rawValue

        let body: [String: String] = [
            "name": name,
            "email": email,
            "subject": subject,
            "message": message,
            "app_name": "FixMate"
        ]

        guard let url = URL(string: "\(backendURL)/api/feedback"),
              let httpBody = try? JSONEncoder().encode(body) else {
            isSubmitting = false
            errorMessage = "Failed to prepare request"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    showSuccess = true
                } else {
                    errorMessage = "Failed to submit. Please try again."
                }
            }
        }.resume()
    }
}
