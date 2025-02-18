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
    // 支出类别
    case food = "餐饮"
    case shopping = "购物"
    case clothing = "服饰"
    case daily = "日用"
    case transport = "交通"
    case entertainment = "娱乐"
    case medical = "医疗"
    case education = "教育"
    case travel = "旅行"
    case beauty = "美容"
    case digital = "数码"
    case pets = "宠物"
    
    // 收入类别
    case salary = "工资"
    case bonus = "奖金"
    case investment = "投资"
    case partTime = "兼职"
    case redPacket = "红包"
    case refund = "退款"
}

enum StatisticsPeriod: String, CaseIterable {
    case week = "周"
    case month = "月"
    case year = "年"
    case all = "全部"
} 