import SwiftUI

struct AddFeedView: View {
    @Environment(FeedService.self) private var feedService
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var urlString = ""
    @State private var category: FeedCategory = .general
    @State private var isValidating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Feed Details") {
                    TextField("Feed Name", text: $name)
                        .textContentType(.name)

                    TextField("RSS Feed URL", text: $urlString)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)

                    Picker("Category", selection: $category) {
                        ForEach(FeedCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.systemImage)
                                .tag(cat)
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button {
                        addFeed()
                    } label: {
                        if isValidating {
                            HStack {
                                ProgressView()
                                Text("Validating feed...")
                            }
                        } else {
                            Text("Add Feed")
                        }
                    }
                    .disabled(name.isEmpty || urlString.isEmpty || isValidating)
                }
            }
            .navigationTitle("Add Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addFeed() {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        let source = FeedSource(name: name, url: url, category: category)
        feedService.addSource(source)
        dismiss()
    }
}
