import SwiftUI

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category = .food
    @State private var amount: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                // 类型选择
                Picker("类型", selection: $selectedType) {
                    Text("支出").tag(TransactionType.expense)
                    Text("收入").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                
                // 类别选择
                Picker("类别", selection: $selectedCategory) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                
                // 金额输入
                HStack {
                    Text("金额")
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("添加记录")
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                },
                trailing: Button("完成") {
                    if let amountDouble = Double(amount) {
                        let newTransaction = TransactionEntity(context: viewContext)
                        newTransaction.id = UUID()
                        newTransaction.amount = amountDouble
                        newTransaction.type = selectedType == .income ? "income" : "expense"
                        newTransaction.category = selectedCategory.rawValue
                        newTransaction.date = Date()
                        
                        do {
                            try viewContext.save()
                            isPresented = false
                        } catch {
                            print("Error saving transaction: \(error)")
                        }
                    }
                }
            )
        }
    }
}
