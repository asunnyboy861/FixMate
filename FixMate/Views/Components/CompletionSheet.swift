import SwiftUI
import PhotosUI

struct CompletionSheet: View {
    let task: MaintenanceTask
    let onComplete: (String?, Decimal?, Data?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var notes = ""
    @State private var costText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showPhotoPicker = false

    var isPro: Bool { StoreKitService.shared.isPro }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Completion Details")
                }

                if isPro {
                    Section {
                        HStack {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $costText)
                                .keyboardType(.decimalPad)
                        }
                    } header: {
                        Text("Cost")
                    }

                    Section {
                        Button {
                            showPhotoPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Add Photo")
                            }
                        }
                        if let photoData, let image = UIImage(data: photoData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    } header: {
                        Text("Photo Record")
                    }
                } else {
                    Section {
                        NavigationLink {
                            ProPaywallView()
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock Cost Tracking & Photos")
                                    .foregroundStyle(Color.appPrimary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mark Done")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let cost: Decimal? = costText.isEmpty ? nil : Decimal(string: costText)
                        onComplete(notes.isEmpty ? nil : notes, cost, photoData)
                    }
                    .bold()
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data), let compressed = PhotoService.compress(image: image) {
                            photoData = compressed
                        }
                    }
                }
            }
        }
    }
}
