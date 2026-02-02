//
//  WrappingStyleView.swift
//  Flowers
//
//  Created by Zhong Lin on 2/2/2026.
//

import SwiftUI

struct WrappingStyleView: View {
    @ObservedObject var viewModel: BouquetViewModel
    @Binding var isPresented: Bool
    
    let ribbonColors: [Color] = [
        .pink, .red, .purple, .blue, .green, .yellow, .orange, .white
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 包装样式选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("包装样式")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(WrappingStyle.allCases, id: \.self) { style in
                                WrappingStyleCard(
                                    style: style,
                                    isSelected: viewModel.currentBouquet.wrappingStyle == style
                                ) {
                                    withAnimation {
                                        viewModel.setWrappingStyle(style)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 丝带颜色选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("丝带颜色")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ribbonColors, id: \.self) { color in
                                    RibbonColorButton(
                                        color: color,
                                        isSelected: viewModel.currentBouquet.ribbonColor == color
                                    ) {
                                        withAnimation {
                                            viewModel.setRibbonColor(color)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 备注
                    VStack(alignment: .leading, spacing: 12) {
                        Text("备注信息")
                            .font(.headline)
                        
                        TextEditor(text: $viewModel.currentBouquet.note)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if viewModel.currentBouquet.note.isEmpty {
                                        Text("添加贺卡内容或特殊要求...")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 12)
                                            .padding(.top, 16)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("包装设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - 包装样式卡片
struct WrappingStyleCard: View {
    let style: WrappingStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(style.icon)
                    .font(.system(size: 40))
                
                Text(style.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("+¥\(String(format: "%.0f", style.price))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.pink.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 丝带颜色按钮
struct RibbonColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(Color.pink, lineWidth: isSelected ? 3 : 0)
                        .padding(-3)
                )
                .overlay(
                    Group {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(color == .white ? .black : .white)
                        }
                    }
                )
        }
    }
}

#Preview {
    WrappingStyleView(
        viewModel: BouquetViewModel(),
        isPresented: .constant(true)
    )
}
