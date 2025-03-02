import SwiftUI

struct HomeViewSplash: View {
    @Binding var isShowing: Bool
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var coffeeRotation = false
    
    var body: some View {
        ZStack {
            Color.coffeeBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.coffeePrimary)
                    .padding(30)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
                    .scaleEffect(coffeeRotation ? 1.0 : 0.8)
                    .opacity(coffeeRotation ? 1.0 : 0.0)
                
                Text("咖啡大师")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "4E342E"))
                    .padding(.top, 10)
                
                Text("您的私人咖啡顾问")
                    .font(.title3)
                    .foregroundColor(Color(hex: "5D4037"))
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                // 启动动画
                withAnimation(Animation.easeInOut(duration: 1.2)) {
                    coffeeRotation = true
                }
                
                // 整体动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        size = 1.0
                        opacity = 1.0
                    }
                }
                
                // 淡出动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isShowing = false
                    }
                }
            }
        }
    }
} 