import SwiftUI

struct ModelSearchView: View {
    let appState: AppState
    @State private var query = ""
    @State private var models: [HFModel] = []

    var body: some View {
        List(models) { model in
            VStack(alignment: .leading) {
                Text(model.id).font(.headline)
                Text("Downloads: \(model.downloads ?? 0)")
            }
        }
        .searchable(text: $query)
        .navigationTitle("Model Search")
    }
}
