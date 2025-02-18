import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionEntity
    
    // 格式化日期
    private var formattedDate: String {
        guard let date = transaction.date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 类别图标
            Image(systemName: CategoryManager.getIcon(for: transaction.category ?? ""))
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    transaction.type == "income" 
                    ? Color.green.opacity(0.8) 
                    : CategoryManager.getColor(for: transaction.category ?? "").opacity(0.8)
                )
                .clipShape(Circle())
            
            // 类别和时间
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category ?? "")
                    .font(.system(size: 16, weight: .medium))
                Text(formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 金额
            Text("\(transaction.type == "income" ? "+" : "-")¥\(String(format: "%.2f", transaction.amount))")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(transaction.type == "income" ? .green : .red)
        }
        .padding(.vertical, 8)
    }
}

// 预览提供者
struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TransactionRow(transaction: sampleTransaction(type: "expense", category: "餐饮", amount: 88.8))
            TransactionRow(transaction: sampleTransaction(type: "income", category: "工资", amount: 6666))
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // 创建样例数据
    static func sampleTransaction(type: String, category: String, amount: Double) -> TransactionEntity {
        let context = PersistenceController.shared.container.viewContext
        let transaction = TransactionEntity(context: context)
        transaction.id = UUID()
        transaction.type = type
        transaction.category = category
        transaction.amount = amount
        transaction.date = Date()
        return transaction
    }
}

