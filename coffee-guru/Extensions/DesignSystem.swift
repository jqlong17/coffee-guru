 import SwiftUI

// MARK: - 设计系统
/// 咖啡大师应用的设计系统
/// 集中定义所有UI相关的常量，确保整个应用的一致性

struct CoffeeGuru {
    // MARK: - 尺寸
    struct Dimensions {
        // 内容边距
        struct Padding {
            /// 标准页面水平边距
            static let horizontal: CGFloat = 16
            /// 标准页面垂直边距
            static let vertical: CGFloat = 16
            /// 卡片内部水平边距
            static let cardHorizontal: CGFloat = 12
            /// 卡片内部垂直边距
            static let cardVertical: CGFloat = 12
            /// 元素之间的小间距
            static let small: CGFloat = 4
            /// 元素之间的中等间距
            static let medium: CGFloat = 8
            /// 元素之间的大间距
            static let large: CGFloat = 16
            /// 元素之间的超大间距
            static let extraLarge: CGFloat = 24
            /// 段落间距
            static let section: CGFloat = 32
        }
        
        // 卡片尺寸
        struct Card {
            /// 标准卡片高度
            static let height: CGFloat = 180
            /// 标准卡片宽度（根据屏幕宽度自动计算）
            static func width(in geometry: GeometryProxy) -> CGFloat {
                let availableWidth = geometry.size.width - Padding.horizontal * 2 - Padding.medium
                return availableWidth / 2
            }
            /// 卡片图片高度
            static let imageHeight: CGFloat = 120
            /// 精选卡片高度
            static let featuredHeight: CGFloat = 160
            /// 精选卡片图片宽度
            static let featuredImageWidth: CGFloat = 110
        }
        
        // 字体尺寸
        struct FontSize {
            /// 标题字体大小
            static let title: CGFloat = 28
            /// 副标题字体大小
            static let subtitle: CGFloat = 22
            /// 卡片标题字体大小
            static let cardTitle: CGFloat = 16
            /// 正文字体大小
            static let body: CGFloat = 14
            /// 小字体大小
            static let small: CGFloat = 12
            /// 超小字体大小
            static let extraSmall: CGFloat = 10
        }
        
        // 图标尺寸
        struct Icon {
            /// 小图标尺寸
            static let small: CGFloat = 16
            /// 中等图标尺寸
            static let medium: CGFloat = 24
            /// 大图标尺寸
            static let large: CGFloat = 32
        }
    }
    
    // MARK: - 样式
    struct Style {
        // 圆角
        struct CornerRadius {
            /// 标准圆角
            static let standard: CGFloat = 12
            /// 小圆角
            static let small: CGFloat = 8
            /// 大圆角
            static let large: CGFloat = 16
            /// 圆形（用于按钮等）
            static let circle: CGFloat = 999
        }
        
        // 阴影
        struct Shadow {
            /// 轻微阴影
            static let light: Shadow = Shadow(
                color: Color.black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2
            )
            
            /// 标准阴影
            static let standard: Shadow = Shadow(
                color: Color.black.opacity(0.15),
                radius: 6,
                x: 0,
                y: 3
            )
            
            /// 强烈阴影
            static let strong: Shadow = Shadow(
                color: Color.black.opacity(0.2),
                radius: 10,
                x: 0,
                y: 5
            )
            
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
            
            /// 应用阴影到视图
            func apply<T: View>(to view: T) -> some View {
                view.shadow(
                    color: color,
                    radius: radius,
                    x: x,
                    y: y
                )
            }
        }
        
        // 动画
        struct Animation {
            /// 标准动画持续时间
            static let duration: Double = 0.3
            /// 标准动画曲线
            static let standard = SwiftUI.Animation.easeInOut(duration: duration)
            /// 弹性动画
            static let spring = SwiftUI.Animation.spring(
                response: 0.4,
                dampingFraction: 0.7,
                blendDuration: 0.3
            )
        }
    }
    
    // MARK: - 主题
    struct Theme {
        // 颜色主题
        struct Colors {
            // 使用已有的颜色扩展
            static let primary = Color.coffeePrimary
            static let secondary = Color.coffeeSecondary
            static let accent = Color.coffeeAccent
            static let lightBrown = Color.coffeeLightBrown
            static let background = Color.coffeeBackground
            static let textLight = Color.coffeeTextLight
            
            // 添加新的颜色
            static let textDark = Color(red: 0.2, green: 0.2, blue: 0.2)
            static let textMedium = Color(red: 0.4, green: 0.4, blue: 0.4)
            static let cardBackground = Color.white
            static let divider = Color(red: 0.9, green: 0.9, blue: 0.9)
            static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
            static let error = Color(red: 0.8, green: 0.2, blue: 0.2)
            static let warning = Color(red: 0.95, green: 0.65, blue: 0.2)
        }
    }
}

// MARK: - 视图修饰符扩展
extension View {
    /// 应用标准卡片样式
    func coffeeCardStyle() -> some View {
        self
            .background(CoffeeGuru.Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(
                cornerRadius: CoffeeGuru.Style.CornerRadius.standard,
                style: .continuous
            ))
            .shadow(
                color: CoffeeGuru.Style.Shadow.standard.color,
                radius: CoffeeGuru.Style.Shadow.standard.radius,
                x: CoffeeGuru.Style.Shadow.standard.x,
                y: CoffeeGuru.Style.Shadow.standard.y
            )
    }
    
    /// 应用标准按钮样式
    func coffeeButtonStyle(isAccent: Bool = true) -> some View {
        self
            .padding(.horizontal, CoffeeGuru.Dimensions.Padding.large)
            .padding(.vertical, CoffeeGuru.Dimensions.Padding.medium)
            .background(
                RoundedRectangle(cornerRadius: CoffeeGuru.Style.CornerRadius.standard)
                    .fill(isAccent ? CoffeeGuru.Theme.Colors.accent : CoffeeGuru.Theme.Colors.primary)
            )
            .foregroundColor(CoffeeGuru.Theme.Colors.textLight)
    }
}