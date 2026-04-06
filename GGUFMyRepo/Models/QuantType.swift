import Foundation

enum QuantType: String, CaseIterable, Codable, Identifiable {
    case q8_0 = "Q8_0"
    case q6_k = "Q6_K"
    case q5_k_m = "Q5_K_M"
    case q4_k_m = "Q4_K_M"
    case q4_0 = "Q4_0"
    case q3_k_m = "Q3_K_M"

    var id: String { rawValue }

    var bitsPerWeight: Double {
        switch self {
        case .q8_0: return 8
        case .q6_k: return 6
        case .q5_k_m: return 5
        case .q4_k_m, .q4_0: return 4
        case .q3_k_m: return 3
        }
    }

    var qualityStars: Int {
        switch self {
        case .q8_0: return 5
        case .q6_k: return 4
        case .q5_k_m: return 4
        case .q4_k_m: return 3
        case .q4_0: return 2
        case .q3_k_m: return 2
        }
    }

    var speedStars: Int {
        switch self {
        case .q8_0: return 2
        case .q6_k: return 3
        case .q5_k_m: return 4
        case .q4_k_m, .q4_0: return 5
        case .q3_k_m: return 5
        }
    }

    var llamaFtype: Int32 {
        switch self {
        case .q4_0: return 2
        case .q8_0: return 7
        case .q5_k_m: return 17
        case .q3_k_m: return 12
        case .q4_k_m: return 15
        case .q6_k: return 18
        }
    }
}
