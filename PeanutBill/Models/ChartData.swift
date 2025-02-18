import Foundation

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let category: String
} 