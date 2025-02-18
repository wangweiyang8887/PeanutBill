import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedPeriod: StatisticsPeriod = .month
    @State private var showingIncome = false // 控制显示收入还是支出图表
    
    // 获取统计时间范围
    private var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let endDate = now // 使用当前时间作为结束时间，而不是日开始时间
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        case .all:
            startDate = Date.distantPast
        }
        return (startDate, endDate)
    }
    
    // 使用计算属性来获取过滤后的交易记录
    private var filteredTransactions: [TransactionEntity] {
        transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= dateRange.start && date <= dateRange.end
        }
    }
    
    // 计算统计数据
    private var statistics: (income: Double, expense: Double, categories: [(String, Double)]) {
        let income = filteredTransactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
        
        let expense = filteredTransactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
        
        // 按类别统计支出
        var categoryDict: [String: Double] = [:]
        filteredTransactions
            .filter { $0.type == "expense" }
            .forEach { transaction in
                if let category = transaction.category {
                    categoryDict[category, default: 0] += transaction.amount
                }
            }
        
        let sortedCategories = categoryDict.sorted { $0.value > $1.value }
        
        return (income, expense, sortedCategories)
    }
    
    // 获取所有交易记录的 FetchRequest
    @FetchRequest(
        entity: TransactionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)],
        animation: .default
    ) private var transactions: FetchedResults<TransactionEntity>
    
    // 处理图表数据
    private var chartData: [ChartData] {
        let calendar = Calendar.current
        var result: [ChartData] = []
        
        // 按照选定的时间段对数据进行分组
        let groupedTransactions = Dictionary(grouping: filteredTransactions) { transaction -> Date in
            guard let date = transaction.date else { return Date() }
            
            switch selectedPeriod {
            case .week:
                // 按天分组
                return calendar.startOfDay(for: date)
            case .month:
                // 按天分组
                return calendar.startOfDay(for: date)
            case .year:
                // 按月分组
                let components = calendar.dateComponents([.year, .month], from: date)
                return calendar.date(from: components)!
            case .all:
                // 按年分组
                let components = calendar.dateComponents([.year], from: date)
                return calendar.date(from: components)!
            }
        }
        
        // 处理每个分组的数据
        for (date, transactions) in groupedTransactions {
            let filteredTransactions = transactions.filter { $0.type == (showingIncome ? "income" : "expense") }
            
            // 按类别分组
            let categoryGroups = Dictionary(grouping: filteredTransactions) { $0.category ?? "其他" }
            
            for (category, categoryTransactions) in categoryGroups {
                let totalAmount = categoryTransactions.reduce(0) { $0 + $1.amount }
                result.append(ChartData(date: date, amount: totalAmount, category: category))
            }
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    // 格式化日期标签
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .week:
            formatter.dateFormat = "MM/dd"
        case .month:
            formatter.dateFormat = "dd"
        case .year:
            formatter.dateFormat = "MM月"
        case .all:
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: date)
    }
    
    var body: some View {
        List {
            // 时间范围选择
            Section {
                Picker("统计周期", selection: $selectedPeriod) {
                    ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 图表部分
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(showingIncome ? "收入趋势" : "支出趋势")
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
                    
                    if !chartData.isEmpty {
                        Chart {
                            ForEach(chartData) { item in
                                BarMark(
                                    x: .value("日期", item.date),
                                    y: .value("金额", item.amount)
                                )
                                .foregroundStyle(by: .value("类别", item.category))
                            }
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        Text(formatDate(date))
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisValueLabel {
                                    if let amount = value.as(Double.self) {
                                        Text("¥\(String(format: "%.0f", amount))")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("暂无数据")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 收支总览
            Section("收支总览") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("收入")
                            .foregroundColor(.gray)
                        Text("¥\(String(format: "%.2f", statistics.income))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("支出")
                            .foregroundColor(.gray)
                        Text("¥\(String(format: "%.2f", statistics.expense))")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                
                HStack {
                    Text("结余")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("¥\(String(format: "%.2f", statistics.income - statistics.expense))")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            // 支出分类统计
            if !statistics.categories.isEmpty {
                Section("支出分类统计") {
                    ForEach(statistics.categories, id: \.0) { category, amount in
                        HStack {
                            Text(category)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("¥\(String(format: "%.2f", amount))")
                                    .foregroundColor(.red)
                                Text(String(format: "%.1f%%", (amount / statistics.expense) * 100))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("统计")
    }
}
