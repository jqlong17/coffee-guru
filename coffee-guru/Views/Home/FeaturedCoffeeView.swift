import SwiftUI

// 精选咖啡视图
struct FeaturedCoffeeView: View {
    let featuredCoffee: CoffeeItem?
    let isLoadingData: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日精选")
                .font(.system(size: CoffeeGuru.Dimensions.FontSize.subtitle, weight: .bold))
                .foregroundColor(Color(hex: "5D4037"))
            
            if let coffee = featuredCoffee, !isLoadingData {
                // 使用NavigationLink包裹ZStack，实现点击导航
                NavigationLink(value: coffee.name) {
                    ZStack(alignment: .center) {
                        Rectangle()
                            .fill(CoffeeGuru.Theme.Colors.lightBrown.opacity(0.3))
                            .frame(height: CoffeeGuru.Dimensions.Card.featuredHeight - 30)
                            .cornerRadius(CoffeeGuru.Style.CornerRadius.standard)
                        
                        VStack(alignment: .center, spacing: 6) {
                            Text(coffee.name)
                                .font(.system(size: CoffeeGuru.Dimensions.FontSize.cardTitle, weight: .bold))
                                .foregroundColor(Color(hex: "4E342E"))
                                .padding(.bottom, 2)
                            
                            Text(coffee.description)
                                .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                                .foregroundColor(Color(hex: "5D4037"))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: CoffeeGuru.Style.CornerRadius.small)
                                .fill(Color.white.opacity(0.9))
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(8)
                    }
                    .transition(.scale)
                    .coffeeCardStyle()
                }
                .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
            } else {
                // 加载中或无数据时显示的视图
                ZStack(alignment: .center) {
                    Rectangle()
                        .fill(CoffeeGuru.Theme.Colors.lightBrown.opacity(0.3))
                        .frame(height: CoffeeGuru.Dimensions.Card.featuredHeight - 30)
                        .cornerRadius(CoffeeGuru.Style.CornerRadius.standard)
                    
                    if isLoadingData {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: CoffeeGuru.Theme.Colors.primary))
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(alignment: .center, spacing: 6) {
                            Text("正在获取精选咖啡...")
                                .font(.system(size: CoffeeGuru.Dimensions.FontSize.cardTitle, weight: .bold))
                                .foregroundColor(Color(hex: "4E342E"))
                            
                            Text("请稍候")
                                .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                                .foregroundColor(Color(hex: "5D4037"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: CoffeeGuru.Style.CornerRadius.small)
                                .fill(Color.white.opacity(0.9))
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(8)
                    }
                }
                .transition(.scale)
                .coffeeCardStyle()
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
    }
} 