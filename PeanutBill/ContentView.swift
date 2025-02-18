//
//  ContentView.swift
//  PeanutBill
//
//  Created by evan on 2025/2/18.
//

import SwiftUI
import CoreData

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

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TransactionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<TransactionEntity>
    
    @State private var showingAddTransaction = false
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 账本页面
            NavigationView {
                VStack {
                    // 月份选择器
                    DatePicker("选择月份", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                    
                    // 交易记录列表
                    List(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                .navigationTitle("账本")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddTransaction = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("账本")
            }
            .tag(0)
            
            // 统计页面
            NavigationView {
                Text("统计页面")
                    .navigationTitle("统计")
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("统计")
            }
            .tag(1)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(isPresented: $showingAddTransaction)
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
