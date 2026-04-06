import SwiftUI

struct FilePickerSheet: View {
    let files: [String]

    var body: some View {
        List(files, id: \.self) { file in
            Text(file)
        }
    }
}
