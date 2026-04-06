import SwiftUI

struct JobHistoryView: View {
    let appState: AppState

    var body: some View {
        List(appState.jobs) { job in
            VStack(alignment: .leading) {
                Text(job.modelId).font(.headline)
                Text(job.quantType.rawValue)
            }
        }
        .navigationTitle("History")
    }
}
