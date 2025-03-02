import SwiftUI

struct HomeViewSplash: View {
    @Binding var isShowing: Bool
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        ZStack {
            Color.coffeeBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.coffeePrimary)
                
                Text("咖啡大师")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.coffeePrimary)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                // 简化动画
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    size = 1.0
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    opacity = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isShowing = false
                    }
                }
            }
        }
    }
} 