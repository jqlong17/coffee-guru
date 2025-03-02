import SwiftUI

struct ToolsView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.coffeeBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("咖啡工具")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.coffeePrimary)
                
                Image(systemName: "gearshape.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.coffeeAccent)
                    .padding(30)
                    // 简化旋转动画
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                            isAnimating = true
                        }
                    }
                
                Text("敬请期待")
                    .font(.title3)
                    .foregroundColor(.coffeeSecondary)
            }
        }
    }
}

struct ProfileView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.coffeeBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("我的")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.coffeePrimary)
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.coffeeAccent)
                    .padding(30)
                    // 简化缩放动画
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                    }
                
                Text("敬请期待")
                    .font(.title3)
                    .foregroundColor(.coffeeSecondary)
            }
        }
    }
} 