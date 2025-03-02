import SwiftUI
import UIKit

// 导入模型和视图
// 通过编译时，系统会自动链接项目中的其他文件
// CoffeeItem模型和CoffeeDetailView会自动被找到，不需要显式导入
// 颜色扩展也会被自动找到

// 咖啡卡片视图
struct CoffeeCard: View {
    let coffee: CoffeeItem
    @State private var isPressed = false
    @State private var navigateToDetail = false
    
    var body: some View {
        ZStack {
            // 使用新的NavigationLink API
            NavigationLink(value: coffee.name) {
                // 咖啡卡片内容
                CardContent(coffee: coffee, isPressed: $isPressed)
            }
            .buttonStyle(PlainButtonStyle()) // 移除按钮样式
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    // 添加触觉反馈
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    // 添加按压效果
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = false
                        }
                    }
                }
            )
        }
    }
}

// 咖啡卡片内容视图
struct CardContent: View {
    let coffee: CoffeeItem
    @Binding var isPressed: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Rectangle()
                    .fill(Color.coffeeLightBrown.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(12)
                
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.coffeeAccent)
                    .padding(30)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(coffee.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.coffeePrimary)
                    .lineLimit(1)
                
                Text(coffee.description)
                    .font(.system(size: 12))
                    .foregroundColor(.coffeeSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 30)
                
                HStack {
                    ForEach(0..<5) { i in
                        Image(systemName: i < coffee.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(.coffeeSecondary)
                    }
                    
                    Spacer()
                    
                    Text("详情")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.coffeeAccent)
                        )
                }
            }
            .padding(.vertical, 8)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
} 