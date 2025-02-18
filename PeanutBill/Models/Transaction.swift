import Foundation

struct Transaction: Identifiable {
    let id = UUID()
    let type: TransactionType
    let category: Category
    let amount: Double
    let date: Date
}

enum TransactionType {
    case income
    case expense
}

enum Category: String, CaseIterable {
    case food = "餐饮"
    case shopping = "购物"
    case clothing = "服饰"
    case daily = "日用"
    case transport = "交通"
    case entertainment = "娱乐"
}

enum StatisticsPeriod: String, CaseIterable {
    case week = "周"
    case month = "月"
    case year = "年"
    case all = "全部"
} 