//
//  OrderFormView.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import SwiftUI

struct OrderFormView: View {
    @ObservedObject var viewModel: BouquetViewModel
    @Binding var isPresented: Bool
    
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var deliveryAddress = ""
    @State private var deliveryDate = Date()
    @State private var specialRequests = ""
    @State private var showingConfirmation = false
    @State private var submittedOrder: FlowerOrder?
    
    var isFormValid: Bool {
        !customerName.isEmpty && !customerPhone.isEmpty && !deliveryAddress.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 花束预览摘要
                Section {
                    BouquetSummaryRow(bouquet: viewModel.currentBouquet)
                }
                
                // 联系信息
                Section(header: Text("联系信息")) {
                    TextField("您的姓名", text: $customerName)
                    
                    TextField("联系电话", text: $customerPhone)
                        .keyboardType(.phonePad)
                }
                
                // 配送信息
                Section(header: Text("配送信息")) {
                    TextField("配送地址", text: $deliveryAddress)
                    
                    DatePicker(
                        "期望送达日期",
                        selection: $deliveryDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // 特殊要求
                Section(header: Text("特殊要求（可选）")) {
                    TextEditor(text: $specialRequests)
                        .frame(height: 80)
                }
                
                // 价格明细
                Section(header: Text("价格明细")) {
                    ForEach(viewModel.currentBouquet.items) { item in
                        HStack {
                            Text("\(item.flower.emoji) \(item.flower.name)")
                            Text("×\(item.quantity)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("¥\(String(format: "%.0f", item.flower.price * Double(item.quantity)))")
                        }
                        .font(.subheadline)
                    }
                    
                    HStack {
                        Text("包装费用")
                        Text("(\(viewModel.currentBouquet.wrappingStyle.rawValue))")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("¥\(String(format: "%.0f", viewModel.currentBouquet.wrappingStyle.price))")
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Text("合计")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("¥\(String(format: "%.2f", viewModel.currentBouquet.totalPrice))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }
                }
                
                // 提交按钮
                Section {
                    Button(action: submitOrder) {
                        HStack {
                            Spacer()
                            Text("提交订单")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                    .foregroundColor(isFormValid ? .white : .gray)
                    .listRowBackground(isFormValid ? Color.pink : Color.gray.opacity(0.3))
                }
            }
            .navigationTitle("确认订单")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
            .sheet(isPresented: $showingConfirmation) {
                if let order = submittedOrder {
                    OrderConfirmationView(
                        order: order,
                        orderDescription: viewModel.generateOrderDescription(),
                        onDismiss: {
                            showingConfirmation = false
                            isPresented = false
                            viewModel.clearBouquet()
                        }
                    )
                }
            }
        }
    }
    
    private func submitOrder() {
        let order = viewModel.submitOrder(
            customerName: customerName,
            customerPhone: customerPhone,
            deliveryAddress: deliveryAddress,
            deliveryDate: deliveryDate,
            specialRequests: specialRequests
        )
        submittedOrder = order
        showingConfirmation = true
    }
}

// MARK: - 花束摘要行
struct BouquetSummaryRow: View {
    let bouquet: Bouquet
    
    var body: some View {
        HStack(spacing: 12) {
            // 花束图标
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                // 显示前几种花的emoji
                HStack(spacing: -8) {
                    ForEach(bouquet.items.prefix(3)) { item in
                        Text(item.flower.emoji)
                            .font(.title2)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bouquet.name)
                    .font(.headline)
                
                Text("\(bouquet.totalFlowers) 支花 · \(bouquet.wrappingStyle.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("¥\(String(format: "%.0f", bouquet.totalPrice))")
                .font(.headline)
                .foregroundColor(.pink)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 订单确认视图
struct OrderConfirmationView: View {
    let order: FlowerOrder
    let orderDescription: String
    let onDismiss: () -> Void
    
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 成功图标
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            
            Text("订单提交成功！")
                .font(.title)
                .fontWeight(.bold)
            
            Text("订单编号：\(order.id.uuidString.prefix(8).uppercased())")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 订单详情卡片
            VStack(alignment: .leading, spacing: 12) {
                Text("订单详情")
                    .font(.headline)
                
                Divider()
                
                OrderDetailRow(label: "收货人", value: order.customerName)
                OrderDetailRow(label: "联系电话", value: order.customerPhone)
                OrderDetailRow(label: "配送地址", value: order.deliveryAddress)
                OrderDetailRow(label: "期望送达", value: formatDate(order.deliveryDate))
                OrderDetailRow(label: "订单金额", value: "¥\(String(format: "%.2f", order.bouquet.totalPrice))")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // 操作按钮
            VStack(spacing: 12) {
                // 分享给商家按钮
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("发送给商家")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
                }
                
                // 返回首页按钮
                Button(action: onDismiss) {
                    Text("返回首页")
                        .font(.headline)
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [orderDescription])
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 订单详情行
struct OrderDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - 分享功能
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let viewModel = BouquetViewModel()
    viewModel.addFlower(Flower.sampleFlowers[0])
    viewModel.addFlower(Flower.sampleFlowers[1])
    
    return OrderFormView(
        viewModel: viewModel,
        isPresented: .constant(true)
    )
}
