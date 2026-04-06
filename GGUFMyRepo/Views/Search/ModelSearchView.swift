import SwiftUI

@MainActor
@Observable
final class ModelSearchViewModel {
    var query: String = ""
    var models: [HFModel] = []
    var isLoading = false
    var errorMessage: String?

    private let client = HFClient()

    func performSearchDebounced() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            models = []
            errorMessage = nil
            return
        }

        do {
            try await Task.sleep(nanoseconds: 400_000_000)
            guard term == query.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            isLoading = true
            errorMessage = nil
            models = try await client.searchModels(query: term)
            isLoading = false
        } catch is CancellationError {
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Search failed. Please try again."
        }
    }
}

struct ModelSearchView: View {
    let appState: AppState
    @State private var viewModel = ModelSearchViewModel()

    var body: some View {
        List(viewModel.models) { model in
            VStack(alignment: .leading, spacing: 4) {
                Text(model.id).font(.headline)
                HStack {
                    Label("\(model.downloads ?? 0)", systemImage: "arrow.down.circle.fill")
                    Label("\(model.likes ?? 0)", systemImage: "heart")
                    if let tag = model.pipelineTag {
                        Text(tag).foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Searching GGUF models…")
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView("Search Error", systemImage: "exclamationmark.triangle", description: Text(message))
            } else if viewModel.models.isEmpty, !viewModel.query.isEmpty {
                ContentUnavailableView.search
            }
        }
        .searchable(text: $viewModel.query)
        .task(id: viewModel.query) {
            await viewModel.performSearchDebounced()
        }
        .navigationTitle("Model Search")
    }
}
