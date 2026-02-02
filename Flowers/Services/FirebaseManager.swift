//
//  FirebaseManager.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Combine

// MARK: - Firebase 管理器
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let db: Firestore
    let auth: Auth
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        
        // 监听认证状态变化
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = user != nil
        }
    }
}

// MARK: - Firestore 数据模型（可编码）

/// 花卉数据模型（用于 Firestore）
struct FlowerData: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let englishName: String
    let colorHex: String
    let price: Double
    let emoji: String
    let category: String
    let description: String
    let isAvailable: Bool
    let stockQuantity: Int
    
    var color: Color {
        Color(hex: colorHex) ?? .pink
    }
    
    func toFlower() -> Flower {
        Flower(
            id: id ?? UUID().uuidString,
            name: name,
            englishName: englishName,
            color: color,
            price: price,
            emoji: emoji,
            category: FlowerCategory(rawValue: category) ?? .rose,
            description: description
        )
    }
}

/// 花束项数据模型
struct BouquetItemData: Codable {
    let flowerId: String
    let flowerName: String
    let flowerEmoji: String
    let flowerPrice: Double
    var quantity: Int
    var positionX: Double
    var positionY: Double
    var scale: Double
    var rotation: Double
}

/// 花束数据模型
struct BouquetData: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var items: [BouquetItemData]
    var wrappingStyle: String
    var ribbonColorHex: String
    var note: String
    let createdAt: Date
    let userId: String?
    var totalPrice: Double
}

/// 订单数据模型
struct OrderData: Codable, Identifiable {
    @DocumentID var id: String?
    let bouquetId: String
    let bouquetData: BouquetData
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let deliveryDate: Date
    let specialRequests: String
    var status: String
    let createdAt: Date
    let userId: String?
}

// MARK: - Color 扩展
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#FF69B4" }
        
        let r = components.count > 0 ? components[0] : 0
        let g = components.count > 1 ? components[1] : 0
        let b = components.count > 2 ? components[2] : 0
        
        return String(format: "#%02X%02X%02X",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
}

import SwiftUI
