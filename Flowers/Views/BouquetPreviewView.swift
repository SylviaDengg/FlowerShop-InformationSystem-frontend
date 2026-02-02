//
//  BouquetPreviewView.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import SwiftUI

struct BouquetPreviewView: View {
    @ObservedObject var viewModel: BouquetViewModel
    @State private var selectedItemId: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 预览区域
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 包装底部
                WrappingBackground(style: viewModel.currentBouquet.wrappingStyle)
                
                // 花卉展示
                if viewModel.currentBouquet.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("点击下方添加花卉")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("开始创建你的专属花束")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    // 显示花卉
                    ForEach(viewModel.currentBouquet.items) { item in
                        FlowerItemView(
                            item: item,
                            isSelected: selectedItemId == item.id,
                            onTap: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedItemId = selectedItemId == item.id ? nil : item.id
                                }
                            },
                            onDrag: { newPosition in
                                viewModel.updatePosition(for: item.id, to: newPosition)
                            }
                        )
                    }
                }
                
                // 丝带装饰
                if !viewModel.currentBouquet.items.isEmpty {
                    RibbonView(color: viewModel.currentBouquet.ribbonColor)
                        .offset(y: 120)
                }
            }
            .frame(height: 350)
            .padding()
            .onTapGesture {
                // 点击空白处取消选择
                selectedItemId = nil
            }
            
            // 价格信息
            PriceSummaryBar(bouquet: viewModel.currentBouquet)
        }
    }
}

// MARK: - 花卉项视图
struct FlowerItemView: View {
    let item: BouquetItem
    let isSelected: Bool
    let onTap: () -> Void
    let onDrag: (CGPoint) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @GestureState private var isDragging = false
    
    var body: some View {
        ZStack {
            // 数量指示器
            if item.quantity > 1 {
                ForEach(1..<min(item.quantity, 5), id: \.self) { i in
                    Text(item.flower.emoji)
                        .font(.system(size: 35 * item.scale))
                        .offset(x: CGFloat(i) * 8, y: CGFloat(i) * -5)
                        .opacity(0.6)
                }
            }
            
            // 主花卉
            Text(item.flower.emoji)
                .font(.system(size: 40 * item.scale))
                .rotationEffect(.degrees(item.rotation))
        }
        .overlay(
            // 选中状态边框
            Circle()
                .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
                .frame(width: 60, height: 60)
        )
        .overlay(
            // 数量标签
            Group {
                if item.quantity > 1 {
                    Text("×\(item.quantity)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.pink)
                        .cornerRadius(10)
                        .offset(x: 25, y: -25)
                }
            }
        )
        .position(item.position)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let newPosition = CGPoint(
                        x: item.position.x + value.translation.width,
                        y: item.position.y + value.translation.height
                    )
                    onDrag(newPosition)
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            onTap()
        }
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isDragging)
    }
}

// MARK: - 包装背景
struct WrappingBackground: View {
    let style: WrappingStyle
    
    var body: some View {
        ZStack {
            switch style {
            case .kraft:
                // 牛皮纸效果
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(red: 0.76, green: 0.6, blue: 0.42))
                    .frame(width: 200, height: 150)
                    .rotationEffect(.degrees(180))
                    .offset(y: 100)
                    .clipShape(
                        BouquetShape()
                    )
                
            case .transparent:
                // 透明纸效果
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 200, height: 150)
                    .offset(y: 100)
                    .clipShape(BouquetShape())
                    .overlay(
                        BouquetShape()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .offset(y: 100)
                    )
                
            case .colorful:
                // 彩色纸效果
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [.pink.opacity(0.6), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 150)
                    .offset(y: 100)
                    .clipShape(BouquetShape())
                
            case .luxury:
                // 高级礼盒效果
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                    .frame(width: 220, height: 100)
                    .offset(y: 130)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                            .frame(width: 220, height: 100)
                            .offset(y: 130)
                    )
                
            case .basket:
                // 花篮效果
                Ellipse()
                    .fill(Color(red: 0.6, green: 0.45, blue: 0.3))
                    .frame(width: 200, height: 80)
                    .offset(y: 140)
                    .overlay(
                        Ellipse()
                            .stroke(Color(red: 0.5, green: 0.35, blue: 0.2), lineWidth: 3)
                            .frame(width: 200, height: 80)
                            .offset(y: 140)
                    )
            }
        }
    }
}

// MARK: - 花束形状
struct BouquetShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.9),
            control: CGPoint(x: width * 0.1, y: height * 0.5)
        )
        path.addLine(to: CGPoint(x: width * 0.4, y: height))
        path.addLine(to: CGPoint(x: width * 0.6, y: height))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.9))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.3),
            control: CGPoint(x: width * 0.9, y: height * 0.5)
        )
        
        return path
    }
}

// MARK: - 丝带视图
struct RibbonView: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // 蝴蝶结左边
            Ellipse()
                .fill(color)
                .frame(width: 30, height: 20)
                .rotationEffect(.degrees(-30))
                .offset(x: -20)
            
            // 蝴蝶结右边
            Ellipse()
                .fill(color)
                .frame(width: 30, height: 20)
                .rotationEffect(.degrees(30))
                .offset(x: 20)
            
            // 中心结
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
            
            // 飘带
            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(0.8))
                .frame(width: 8, height: 40)
                .offset(x: -8, y: 25)
                .rotationEffect(.degrees(-10))
            
            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(0.8))
                .frame(width: 8, height: 40)
                .offset(x: 8, y: 25)
                .rotationEffect(.degrees(10))
        }
    }
}

// MARK: - 价格摘要栏
struct PriceSummaryBar: View {
    let bouquet: Bouquet
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("共 \(bouquet.totalFlowers) 支花")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("包装：\(bouquet.wrappingStyle.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("合计")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("¥\(String(format: "%.2f", bouquet.totalPrice))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -2)
        .padding(.horizontal)
    }
}

#Preview {
    BouquetPreviewView(viewModel: BouquetViewModel())
}
