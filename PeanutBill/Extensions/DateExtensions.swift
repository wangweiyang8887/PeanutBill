import Foundation

extension Date {
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: self)
    }
} 