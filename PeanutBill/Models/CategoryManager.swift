import SwiftUI

// 类别管理器
struct CategoryManager {
    // 类别数据模型
    struct CategoryData: Identifiable {
        let id = UUID()
        let type: TransactionType
        let category: Category
        let icon: String
        let color: Color
    }
    
    // 所有类别数据
    static let categories: [CategoryData] = [
        // 支出类别
        CategoryData(type: .expense, category: .food, icon: "fork.knife", color: .orange),
        CategoryData(type: .expense, category: .shopping, icon: "cart.fill", color: .blue),
        CategoryData(type: .expense, category: .clothing, icon: "tshirt.fill", color: .pink),
        CategoryData(type: .expense, category: .daily, icon: "house.fill", color: .green),
        CategoryData(type: .expense, category: .transport, icon: "car.fill", color: .purple),
        CategoryData(type: .expense, category: .entertainment, icon: "gamecontroller.fill", color: .red),
        CategoryData(type: .expense, category: .medical, icon: "cross.case.fill", color: .red),
        CategoryData(type: .expense, category: .education, icon: "book.fill", color: .blue),
        CategoryData(type: .expense, category: .travel, icon: "airplane", color: .cyan),
        CategoryData(type: .expense, category: .beauty, icon: "heart.fill", color: .pink),
        CategoryData(type: .expense, category: .digital, icon: "desktopcomputer", color: .gray),
        CategoryData(type: .expense, category: .pets, icon: "pawprint.fill", color: .brown),
        
        // 收入类别
        CategoryData(type: .income, category: .salary, icon: "dollarsign.circle.fill", color: .green),
        CategoryData(type: .income, category: .bonus, icon: "gift.fill", color: .orange),
        CategoryData(type: .income, category: .investment, icon: "chart.line.uptrend.xyaxis", color: .blue),
        CategoryData(type: .income, category: .partTime, icon: "briefcase.fill", color: .purple),
        CategoryData(type: .income, category: .redPacket, icon: "envelope.fill", color: .red),
        CategoryData(type: .income, category: .refund, icon: "arrow.uturn.backward.circle.fill", color: .gray)
    ]
    
    // 获取指定类型的类别
    static func getCategories(for type: TransactionType) -> [CategoryData] {
        categories.filter { $0.type == type }
    }
    
    // 根据类别名称获取图标
    static func getIcon(for category: String) -> String {
        categories.first { $0.category.rawValue == category }?.icon ?? "questionmark.circle"
    }
    
    // 根据类别名称获取颜色
    static func getColor(for category: String) -> Color {
        categories.first { $0.category.rawValue == category }?.color ?? .gray
    }
} 