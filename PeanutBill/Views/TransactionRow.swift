import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.category ?? "")
                    .font(.headline)
                Text(transaction.type == "income" ? "收入" : "支出")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(String(format: "%.2f", transaction.amount))
                .foregroundColor(transaction.type == "income" ? .green : .red)
        }
        .padding(.vertical, 8)
    }
}

