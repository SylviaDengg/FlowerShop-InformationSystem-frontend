//
//  BouquetViewModel.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import SwiftUI
import Combine

class BouquetViewModel: ObservableObject {
    @Published var currentBouquet: Bouquet
    @Published var availableFlowers: [Flower] = Flower.sampleFlowers
    @Published var selectedCategory: FlowerCategory? = nil
    @Published var savedBouquets: [Bouquet] = []
    @Published var orders: [FlowerOrder] = []
    
    init() {
        self.currentBouquet = Bouquet(
            name: "我的花束",
            items: [],
            wrappingStyle: .kraft,
            ribbonColor: .pink,
            note: "",
            createdAt: Date()
        )
    }
    
    // MARK: - 花卉筛选
    var filteredFlowers: [Flower] {
        if let category = selectedCategory {
            return availableFlowers.filter { $0.category == category }
        }
        return availableFlowers
    }
    
    // MARK: - 添加花卉到花束
    func addFlower(_ flower: Flower) {
        // 检查是否已存在
        if let index = currentBouquet.items.firstIndex(where: { $0.flower.id == flower.id }) {
            currentBouquet.items[index].quantity += 1
        } else {
            // 随机生成位置
            let randomX = CGFloat.random(in: 80...280)
            let randomY = CGFloat.random(in: 100...300)
            let randomRotation = Double.random(in: -30...30)
            
            let item = BouquetItem(
                flower: flower,
                quantity: 1,
                position: CGPoint(x: randomX, y: randomY),
                scale: 1.0,
                rotation: randomRotation
            )
            currentBouquet.items.append(item)
        }
    }
    
    // MARK: - 减少花卉数量
    func decreaseFlower(_ item: BouquetItem) {
        if let index = currentBouquet.items.firstIndex(where: { $0.id == item.id }) {
            if currentBouquet.items[index].quantity > 1 {
                currentBouquet.items[index].quantity -= 1
            } else {
                currentBouquet.items.remove(at: index)
            }
        }
    }
    
    // MARK: - 移除花卉
    func removeFlower(_ item: BouquetItem) {
        currentBouquet.items.removeAll { $0.id == item.id }
    }
    
    // MARK: - 更新花卉位置
    func updatePosition(for itemId: UUID, to position: CGPoint) {
        if let index = currentBouquet.items.firstIndex(where: { $0.id == itemId }) {
            currentBouquet.items[index].position = position
        }
    }
    
    // MARK: - 更新花卉缩放
    func updateScale(for itemId: UUID, to scale: CGFloat) {
        if let index = currentBouquet.items.firstIndex(where: { $0.id == itemId }) {
            currentBouquet.items[index].scale = scale
        }
    }
    
    // MARK: - 更新花卉旋转
    func updateRotation(for itemId: UUID, to rotation: Double) {
        if let index = currentBouquet.items.firstIndex(where: { $0.id == itemId }) {
            currentBouquet.items[index].rotation = rotation
        }
    }
    
    // MARK: - 更换包装样式
    func setWrappingStyle(_ style: WrappingStyle) {
        currentBouquet.wrappingStyle = style
    }
    
    // MARK: - 设置丝带颜色
    func setRibbonColor(_ color: Color) {
        currentBouquet.ribbonColor = color
    }
    
    // MARK: - 清空花束
    func clearBouquet() {
        currentBouquet = Bouquet(
            name: "我的花束",
            items: [],
            wrappingStyle: .kraft,
            ribbonColor: .pink,
            note: "",
            createdAt: Date()
        )
    }
    
    // MARK: - 保存花束
    func saveBouquet() {
        savedBouquets.append(currentBouquet)
    }
    
    // MARK: - 提交订单
    func submitOrder(
        customerName: String,
        customerPhone: String,
        deliveryAddress: String,
        deliveryDate: Date,
        specialRequests: String
    ) -> FlowerOrder {
        let order = FlowerOrder(
            bouquet: currentBouquet,
            customerName: customerName,
            customerPhone: customerPhone,
            deliveryAddress: deliveryAddress,
            deliveryDate: deliveryDate,
            specialRequests: specialRequests,
            status: .pending,
            createdAt: Date()
        )
        orders.append(order)
        return order
    }
    
    // MARK: - 生成订单描述（发送给商家）
    func generateOrderDescription() -> String {
        var description = "【花束订单】\n"
        description += "花束名称：\(currentBouquet.name)\n"
        description += "------------------------\n"
        description += "花材清单：\n"
        
        for item in currentBouquet.items {
            description += "  • \(item.flower.name) x \(item.quantity) - ¥\(item.flower.price * Double(item.quantity))\n"
        }
        
        description += "------------------------\n"
        description += "包装样式：\(currentBouquet.wrappingStyle.rawValue) \(currentBouquet.wrappingStyle.icon)\n"
        description += "包装费用：¥\(currentBouquet.wrappingStyle.price)\n"
        description += "------------------------\n"
        description += "总计：¥\(String(format: "%.2f", currentBouquet.totalPrice))\n"
        
        if !currentBouquet.note.isEmpty {
            description += "备注：\(currentBouquet.note)\n"
        }
        
        return description
    }
}
