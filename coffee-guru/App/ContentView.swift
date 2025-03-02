import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                // 启动画面
                SplashView()
                    .onAppear {
                        // 延迟加载主界面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                self.isLoading = false
                            }
                        }
                    }
            } else {
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
    }
}

// 启动画面
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
                    .rotationEffect(Angle(degrees: coffeeRotation ? 360 : 0))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                            coffeeRotation = true
                        }
                    }
                
                Text("咖啡大师")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.coffeePrimary)
                    .padding(.top, 20)
                
                Text("您的私人咖啡顾问")
                    .font(.title3)
                    .foregroundColor(.coffeeSecondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 