//
//  FlowerService.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import Foundation
import FirebaseFirestore
import Combine

// MARK: - 花卉服务
class FlowerService: ObservableObject {
    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?
    
    @Published var flowers: [FlowerData] = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        fetchFlowers()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - 获取所有花卉（实时监听）
    func fetchFlowers() {
        isLoading = true
        
        listener = db.collection("flowers")
            .whereField("isAvailable", isEqualTo: true)
            .order(by: "category")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    print("Error fetching flowers: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self?.flowers = []
                    return
                }
                
                self?.flowers = documents.compactMap { doc in
                    try? doc.data(as: FlowerData.self)
                }
            }
    }
    
    // MARK: - 按分类获取花卉
    func fetchFlowersByCategory(_ category: String, completion: @escaping ([FlowerData]) -> Void) {
        db.collection("flowers")
            .whereField("category", isEqualTo: category)
            .whereField("isAvailable", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching flowers by category: \(error)")
                    completion([])
                    return
                }
                
                let flowers = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: FlowerData.self)
                } ?? []
                
                completion(flowers)
            }
    }
    
    // MARK: - 添加示例花卉数据（首次初始化用）
    func seedSampleFlowers() {
        let sampleFlowers: [[String: Any]] = [
            // 玫瑰
            ["name": "红玫瑰", "englishName": "Red Rose", "colorHex": "#FF0000", "price": 8.0, "emoji": "🌹", "category": "玫瑰", "description": "热情的红玫瑰，代表热烈的爱", "isAvailable": true, "stockQuantity": 100],
            ["name": "粉玫瑰", "englishName": "Pink Rose", "colorHex": "#FFC0CB", "price": 8.0, "emoji": "🌹", "category": "玫瑰", "description": "温柔的粉玫瑰，代表初恋", "isAvailable": true, "stockQuantity": 100],
            ["name": "白玫瑰", "englishName": "White Rose", "colorHex": "#FFFFFF", "price": 8.0, "emoji": "🤍", "category": "玫瑰", "description": "纯洁的白玫瑰，代表纯真", "isAvailable": true, "stockQuantity": 100],
            ["name": "香槟玫瑰", "englishName": "Champagne Rose", "colorHex": "#F5E6D3", "price": 10.0, "emoji": "🌹", "category": "玫瑰", "description": "优雅的香槟玫瑰", "isAvailable": true, "stockQuantity": 80],
            
            // 郁金香
            ["name": "红郁金香", "englishName": "Red Tulip", "colorHex": "#FF0000", "price": 6.0, "emoji": "🌷", "category": "郁金香", "description": "热情奔放的红郁金香", "isAvailable": true, "stockQuantity": 60],
            ["name": "粉郁金香", "englishName": "Pink Tulip", "colorHex": "#FFC0CB", "price": 6.0, "emoji": "🌷", "category": "郁金香", "description": "可爱的粉郁金香", "isAvailable": true, "stockQuantity": 60],
            ["name": "紫郁金香", "englishName": "Purple Tulip", "colorHex": "#800080", "price": 7.0, "emoji": "🌷", "category": "郁金香", "description": "神秘的紫郁金香", "isAvailable": true, "stockQuantity": 50],
            
            // 百合
            ["name": "白百合", "englishName": "White Lily", "colorHex": "#FFFFFF", "price": 12.0, "emoji": "💐", "category": "百合", "description": "高雅的白百合，百年好合", "isAvailable": true, "stockQuantity": 40],
            ["name": "粉百合", "englishName": "Pink Lily", "colorHex": "#FFC0CB", "price": 12.0, "emoji": "💐", "category": "百合", "description": "浪漫的粉百合", "isAvailable": true, "stockQuantity": 40],
            
            // 康乃馨
            ["name": "红康乃馨", "englishName": "Red Carnation", "colorHex": "#FF0000", "price": 5.0, "emoji": "🌸", "category": "康乃馨", "description": "母爱的象征", "isAvailable": true, "stockQuantity": 100],
            ["name": "粉康乃馨", "englishName": "Pink Carnation", "colorHex": "#FFC0CB", "price": 5.0, "emoji": "🌸", "category": "康乃馨", "description": "感恩与祝福", "isAvailable": true, "stockQuantity": 100],
            
            // 向日葵
            ["name": "向日葵", "englishName": "Sunflower", "colorHex": "#FFD700", "price": 10.0, "emoji": "🌻", "category": "向日葵", "description": "阳光积极，充满希望", "isAvailable": true, "stockQuantity": 50],
            
            // 绣球花
            ["name": "蓝绣球", "englishName": "Blue Hydrangea", "colorHex": "#0000FF", "price": 25.0, "emoji": "💠", "category": "绣球花", "description": "浪漫的蓝色绣球", "isAvailable": true, "stockQuantity": 30],
            ["name": "粉绣球", "englishName": "Pink Hydrangea", "colorHex": "#FFC0CB", "price": 25.0, "emoji": "💠", "category": "绣球花", "description": "甜美的粉色绣球", "isAvailable": true, "stockQuantity": 30],
            
            // 满天星
            ["name": "白满天星", "englishName": "White Gypsophila", "colorHex": "#FFFFFF", "price": 15.0, "emoji": "✨", "category": "满天星", "description": "浪漫的配花", "isAvailable": true, "stockQuantity": 80],
            ["name": "粉满天星", "englishName": "Pink Gypsophila", "colorHex": "#FFB6C1", "price": 18.0, "emoji": "✨", "category": "满天星", "description": "梦幻的粉色满天星", "isAvailable": true, "stockQuantity": 60],
            
            // 配叶
            ["name": "尤加利叶", "englishName": "Eucalyptus", "colorHex": "#228B22", "price": 8.0, "emoji": "🌿", "category": "配叶", "description": "清新的配叶", "isAvailable": true, "stockQuantity": 100],
            ["name": "蕨类叶", "englishName": "Fern", "colorHex": "#228B22", "price": 5.0, "emoji": "🌿", "category": "配叶", "description": "自然的蕨类", "isAvailable": true, "stockQuantity": 100]
        ]
        
        let batch = db.batch()
        
        for flower in sampleFlowers {
            let docRef = db.collection("flowers").document()
            batch.setData(flower, forDocument: docRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error seeding flowers: \(error)")
            } else {
                print("Sample flowers seeded successfully!")
            }
        }
    }
}
