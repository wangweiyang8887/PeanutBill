//
//  ContentView.swift
//  PeanutBill
//
//  Created by evan on 2025/2/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    @State private var showingIncome = false
    @State private var showingAddTransaction = false
    
    // 计算选中月份的起始日期和结束日期
    private var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        let startDate = calendar.date(from: components)!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        return (startDate, endDate)
    }
    
    // 使用日期范围的 FetchRequest
    @FetchRequest private var transactions: FetchedResults<TransactionEntity>
    
    // 初始化器中设置 FetchRequest
    init() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startDate = calendar.date(from: components)!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        
        _transactions = FetchRequest(
            entity: TransactionEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)],
            predicate: predicate,
            animation: .default
        )
    }
    
    // 计算当前月份的总收入
    private var totalIncome: Double {
        transactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }
    
    // 计算当前月份的总支出
    private var totalExpense: Double {
        transactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }
    
    // 更新日期范围的方法
    private func updateDateRange() {
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                                  dateRange.start as NSDate, 
                                  dateRange.end as NSDate)
        transactions.nsPredicate = predicate
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 账本页面
            NavigationView {
                ZStack {
                    VStack {
                        // 月份选择器
                        DatePicker("选择月份", 
                                 selection: $selectedDate,
                                 displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .padding()
                            .onChange(of: selectedDate) { _, _ in
                                updateDateRange()
                            }
                        
                        List {
                            // 总额显示区域作为第一个 cell
                            Section {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text(showingIncome ? "总收入" : "总支出")
                                            .font(.headline)
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                showingIncome.toggle()
                                            }
                                        }) {
                                            Image(systemName: "arrow.2.squarepath")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Text("¥ \(showingIncome ? String(format: "%.2f", totalIncome) : String(format: "%.2f", totalExpense))")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(showingIncome ? .green : .red)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .transition(.opacity)
                                    
                                    HStack(spacing: 40) {
                                        VStack(alignment: .leading) {
                                            Text("收入")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("¥\(String(format: "%.2f", totalIncome))")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("支出")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("¥\(String(format: "%.2f", totalExpense))")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // 交易记录列表
                            Section {
                                ForEach(transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                    
                    // 悬浮添加按钮
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingAddTransaction = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .navigationTitle("账本")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("账本")
            }
            .tag(0)
            
            // 统计页面
            NavigationView {
                StatisticsView()
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
