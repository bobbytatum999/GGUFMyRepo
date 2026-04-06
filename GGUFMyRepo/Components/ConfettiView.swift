import SwiftUI

struct ConfettiView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<40 {
                    let x = (Double(i) * 37).truncatingRemainder(dividingBy: size.width)
                    let y = (t * 90 + Double(i) * 25).truncatingRemainder(dividingBy: size.height)
                    let rect = CGRect(x: x, y: y, width: 8, height: 8)
                    context.fill(Path(ellipseIn: rect), with: .color([Color.orange, .blue, .pink, .green][i % 4]))
                }
            }
        }
    }
}
