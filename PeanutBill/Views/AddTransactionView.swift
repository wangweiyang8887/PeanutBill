import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let category: Category
    let icon: String
}

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category = .food
    @State private var amount: String = ""
    
    // 网格布局配置
    private let gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 类型切换标签
                Picker("类型", selection: $selectedType) {
                    Text("支出").tag(TransactionType.expense)
                    Text("收入").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 类别选择网格
                        LazyVGrid(columns: gridLayout, spacing: 20) {
                            ForEach(CategoryManager.getCategories(for: selectedType)) { categoryData in
                                CategoryButton(
                                    icon: categoryData.icon,
                                    title: categoryData.category.rawValue,
                                    color: categoryData.color,
                                    isSelected: selectedCategory == categoryData.category
                                ) {
                                    selectedCategory = categoryData.category
                                }
                            }
                        }
                        .padding()
                        
                        // 金额输入
                        HStack {
                            Text("金额")
                                .foregroundColor(.gray)
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .font(.title2)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                    }
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
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// 更新类别按钮组件
struct CategoryButton: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .frame(width: 50, height: 50)
                    .background(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(isSelected ? color : .gray)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? color : .gray)
            }
        }
    }
}
