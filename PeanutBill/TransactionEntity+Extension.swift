import CoreData

extension TransactionEntity {
    // 便利属性和方法
    var typeEnum: TransactionType {
        get {
            return type == "income" ? .income : .expense
        }
        set {
            type = newValue == .income ? "income" : "expense"
        }
    }
    
    var categoryEnum: Category? {
        get {
            return Category(rawValue: category ?? "")
        }
        set {
            category = newValue?.rawValue
        }
    }
} 