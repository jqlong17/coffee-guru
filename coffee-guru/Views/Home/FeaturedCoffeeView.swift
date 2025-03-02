import SwiftUI

// 精选咖啡视图
struct FeaturedCoffeeView: View {
    let featuredCoffee: CoffeeItem?
    let isLoadingData: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: CoffeeGuru.Dimensions.Padding.medium) {
            Text("今日精选")
                .font(.system(size: CoffeeGuru.Dimensions.FontSize.subtitle, weight: .bold))
                .foregroundColor(CoffeeGuru.Theme.Colors.primary)
            
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(CoffeeGuru.Theme.Colors.lightBrown.opacity(0.3))
                    .frame(height: CoffeeGuru.Dimensions.Card.featuredHeight)
                    .cornerRadius(CoffeeGuru.Style.CornerRadius.standard)
                
                if isLoadingData {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CoffeeGuru.Theme.Colors.primary))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let coffee = featuredCoffee {
                    VStack(alignment: .center, spacing: CoffeeGuru.Dimensions.Padding.medium) {
                        Text(coffee.name)
                            .font(.system(size: CoffeeGuru.Dimensions.FontSize.cardTitle, weight: .bold))
                            .foregroundColor(CoffeeGuru.Theme.Colors.primary)
                        
                        Text(coffee.description)
                            .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                            .foregroundColor(CoffeeGuru.Theme.Colors.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(CoffeeGuru.Dimensions.Padding.medium)
                    .background(
                        RoundedRectangle(cornerRadius: CoffeeGuru.Style.CornerRadius.small)
                            .fill(CoffeeGuru.Theme.Colors.cardBackground.opacity(0.8))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(CoffeeGuru.Dimensions.Padding.medium)
                } else {
                    VStack(alignment: .center, spacing: CoffeeGuru.Dimensions.Padding.small) {
                        Text("正在获取精选咖啡...")
                            .font(.system(size: CoffeeGuru.Dimensions.FontSize.cardTitle, weight: .bold))
                            .foregroundColor(CoffeeGuru.Theme.Colors.primary)
                        
                        Text("请稍候")
                            .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                            .foregroundColor(CoffeeGuru.Theme.Colors.secondary)
                    }
                    .padding(CoffeeGuru.Dimensions.Padding.medium)
                    .background(
                        RoundedRectangle(cornerRadius: CoffeeGuru.Style.CornerRadius.small)
                            .fill(CoffeeGuru.Theme.Colors.cardBackground.opacity(0.8))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(CoffeeGuru.Dimensions.Padding.medium)
                }
            }
            .transition(.scale)
            .coffeeCardStyle()
        }
        .padding(.horizontal, CoffeeGuru.Dimensions.Padding.medium)
    }
} 