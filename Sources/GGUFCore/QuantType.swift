import Foundation

public enum QuantType: String, CaseIterable, Codable {
    case q8_0 = "Q8_0"
    case q6_k = "Q6_K"
    case q5_k_m = "Q5_K_M"
    case q4_k_m = "Q4_K_M"
    case q4_0 = "Q4_0"
    case q3_k_m = "Q3_K_M"

    public var bitsPerWeight: Double {
        switch self {
        case .q8_0: return 8
        case .q6_k: return 6
        case .q5_k_m: return 5
        case .q4_k_m, .q4_0: return 4
        case .q3_k_m: return 3
        }
    }
}
