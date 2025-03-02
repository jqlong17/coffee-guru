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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 