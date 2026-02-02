//
//  FlowerModel.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import SwiftUI

// MARK: - 花卉类型
struct Flower: Identifiable, Equatable {
    var id: String = UUID().uuidString
    let name: String
    let englishName: String
    let color: Color
    let price: Double
    let emoji: String  // 使用emoji作为简单展示，后续可替换为实际图片
    let category: FlowerCategory
    let description: String
    
    static func == (lhs: Flower, rhs: Flower) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 花卉分类
enum FlowerCategory: String, CaseIterable {
    case rose = "玫瑰"
    case tulip = "郁金香"
    case lily = "百合"
    case carnation = "康乃馨"
    case sunflower = "向日葵"
    case hydrangea = "绣球花"
    case gypsophila = "满天星"
    case greenery = "配叶"
    
    var icon: String {
        switch self {
        case .rose: return "🌹"
        case .tulip: return "🌷"
        case .lily: return "💐"
        case .carnation: return "🌸"
        case .sunflower: return "🌻"
        case .hydrangea: return "💠"
        case .gypsophila: return "✨"
        case .greenery: return "🌿"
        }
    }
}

// MARK: - 花束中的花卉项
struct BouquetItem: Identifiable {
    var id: String = UUID().uuidString
    let flower: Flower
    var quantity: Int
    var position: CGPoint  // 在预览中的位置
    var scale: CGFloat = 1.0
    var rotation: Double = 0
}

// MARK: - 花束
struct Bouquet: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var items: [BouquetItem]
    var wrappingStyle: WrappingStyle
    var ribbonColor: Color
    var note: String
    let createdAt: Date
    
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.flower.price * Double($1.quantity)) } + wrappingStyle.price
    }
    
    var totalFlowers: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}

// MARK: - 包装样式
enum WrappingStyle: String, CaseIterable {
    case kraft = "牛皮纸"
    case transparent = "透明纸"
    case colorful = "彩色纸"
    case luxury = "高级礼盒"
    case basket = "花篮"
    
    var price: Double {
        switch self {
        case .kraft: return 15
        case .transparent: return 12
        case .colorful: return 18
        case .luxury: return 58
        case .basket: return 45
        }
    }
    
    var icon: String {
        switch self {
        case .kraft: return "📦"
        case .transparent: return "🎁"
        case .colorful: return "🎀"
        case .luxury: return "💎"
        case .basket: return "🧺"
        }
    }
}

// MARK: - 订单
struct FlowerOrder: Identifiable {
    let id = UUID()
    let bouquet: Bouquet
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let deliveryDate: Date
    let specialRequests: String
    var status: OrderStatus
    let createdAt: Date
}

enum OrderStatus: String {
    case pending = "待确认"
    case confirmed = "已确认"
    case preparing = "制作中"
    case ready = "已完成"
    case delivered = "已送达"
}

// MARK: - 示例数据
extension Flower {
    static let sampleFlowers: [Flower] = [
        // 玫瑰
        Flower(name: "红玫瑰", englishName: "Red Rose", color: .red, price: 8, emoji: "🌹", category: .rose, description: "热情的红玫瑰，代表热烈的爱"),
        Flower(name: "粉玫瑰", englishName: "Pink Rose", color: .pink, price: 8, emoji: "🌹", category: .rose, description: "温柔的粉玫瑰，代表初恋"),
        Flower(name: "白玫瑰", englishName: "White Rose", color: .white, price: 8, emoji: "🤍", category: .rose, description: "纯洁的白玫瑰，代表纯真"),
        Flower(name: "香槟玫瑰", englishName: "Champagne Rose", color: Color(red: 0.95, green: 0.9, blue: 0.8), price: 10, emoji: "🌹", category: .rose, description: "优雅的香槟玫瑰"),
        
        // 郁金香
        Flower(name: "红郁金香", englishName: "Red Tulip", color: .red, price: 6, emoji: "🌷", category: .tulip, description: "热情奔放的红郁金香"),
        Flower(name: "粉郁金香", englishName: "Pink Tulip", color: .pink, price: 6, emoji: "🌷", category: .tulip, description: "可爱的粉郁金香"),
        Flower(name: "紫郁金香", englishName: "Purple Tulip", color: .purple, price: 7, emoji: "🌷", category: .tulip, description: "神秘的紫郁金香"),
        
        // 百合
        Flower(name: "白百合", englishName: "White Lily", color: .white, price: 12, emoji: "💐", category: .lily, description: "高雅的白百合，百年好合"),
        Flower(name: "粉百合", englishName: "Pink Lily", color: .pink, price: 12, emoji: "💐", category: .lily, description: "浪漫的粉百合"),
        
        // 康乃馨
        Flower(name: "红康乃馨", englishName: "Red Carnation", color: .red, price: 5, emoji: "🌸", category: .carnation, description: "母爱的象征"),
        Flower(name: "粉康乃馨", englishName: "Pink Carnation", color: .pink, price: 5, emoji: "🌸", category: .carnation, description: "感恩与祝福"),
        
        // 向日葵
        Flower(name: "向日葵", englishName: "Sunflower", color: .yellow, price: 10, emoji: "🌻", category: .sunflower, description: "阳光积极，充满希望"),
        
        // 绣球花
        Flower(name: "蓝绣球", englishName: "Blue Hydrangea", color: .blue, price: 25, emoji: "💠", category: .hydrangea, description: "浪漫的蓝色绣球"),
        Flower(name: "粉绣球", englishName: "Pink Hydrangea", color: .pink, price: 25, emoji: "💠", category: .hydrangea, description: "甜美的粉色绣球"),
        
        // 满天星
        Flower(name: "白满天星", englishName: "White Gypsophila", color: .white, price: 15, emoji: "✨", category: .gypsophila, description: "浪漫的配花"),
        Flower(name: "粉满天星", englishName: "Pink Gypsophila", color: .pink, price: 18, emoji: "✨", category: .gypsophila, description: "梦幻的粉色满天星"),
        
        // 配叶
        Flower(name: "尤加利叶", englishName: "Eucalyptus", color: .green, price: 8, emoji: "🌿", category: .greenery, description: "清新的配叶"),
        Flower(name: "蕨类叶", englishName: "Fern", color: .green, price: 5, emoji: "🌿", category: .greenery, description: "自然的蕨类"),
    ]
}
