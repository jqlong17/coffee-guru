import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        // 主标签视图
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("首页")
                }
                .tag(0)
            
            ToolsView()
                .tabItem {
                    Image(systemName: "hammer.fill")
                    Text("工具")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
                .tag(2)
        }
        .accentColor(.coffeePrimary)
        .onChange(of: selectedTab) { oldValue, newValue in
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }
    }
}

// 保留SplashView的定义，但不再使用它
struct SplashView: View {
    @State private var coffeeRotation = false
    
    var body: some View {
        ZStack {
            Color.coffeeBackground.edgesIgnoringSafeArea(.all)
            
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
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.2)) {
                            coffeeRotation = true
                        }
                    }
                
                Text("咖啡大师")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "4E342E"))
                    .padding(.top, 10)
                
                Text("您的私人咖啡顾问")
                    .font(.title3)
                    .foregroundColor(Color(hex: "5D4037"))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 