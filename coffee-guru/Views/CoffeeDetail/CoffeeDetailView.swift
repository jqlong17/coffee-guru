import SwiftUI
import UIKit
// 不再使用模块导入，而是使用普通导入

// 导入公共组件

// 咖啡详情视图
struct CoffeeDetailView: View {
    let coffeeName: String
    @State private var coffeeDetail: CoffeeDetail?
    @State private var isLoading = true
    @State private var showNetworkError = false
    @State private var errorMessage = "网络连接错误，请检查您的网络设置。"
    @Environment(\.dismiss) private var dismiss
    
    // 添加对 HomeViewModel 的引用
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // 添加顶部导航栏
                    ZStack(alignment: .leading) {
                        // 背景
                        Rectangle()
                            .fill(Color.coffeePrimary)
                            .frame(height: 44)
                            .edgesIgnoringSafeArea(.top)
                        
                        // 返回按钮
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 16)
                        
                        // 标题
                        Text(coffeeName)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .lineLimit(1)
                    }
                    .frame(height: 44)
                    .padding(.top, getSafeAreaTop())
                    
                    // 咖啡内容
                    VStack(alignment: .leading, spacing: 24) {
                        if isLoading {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .coffeePrimary))
                                    .scaleEffect(1.5)
                                
                                Text("正在获取\(coffeeName)的详细信息...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.coffeeSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 60)
                        } else if let detail = coffeeDetail {
                            VStack(alignment: .leading, spacing: 24) {
                                // 咖啡名称
                                Text(detail.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.coffeePrimary)
                                    .padding(.top, 20)
                                
                                // 星级评分
                                HStack {
                                    ForEach(0..<5) { i in
                                        Image(systemName: i < Int(detail.rating) ? "star.fill" : "star")
                                            .foregroundColor(.coffeeAccent)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // 咖啡描述
                                Text(detail.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.coffeeSecondary)
                                    .lineSpacing(6)
                                
                                // 产地信息
                                DetailSection(title: "产地", content: detail.origin)
                                
                                // 风味特点
                                DetailSection(title: "风味特点", content: detail.flavor)
                                
                                // 历史背景
                                DetailSection(title: "历史背景", content: detail.history)
                                
                                // 生豆价格
                                DetailSection(title: "生豆价格", content: detail.price)
                                
                                // 烘焙程度
                                DetailSection(title: "烘焙程度", content: detail.roastLevel)
                                
                                // 冲泡方法
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("推荐冲泡方法")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.coffeePrimary)
                                    
                                    HStack {
                                        ForEach(detail.brewMethods, id: \.self) { method in
                                            Text(method)
                                                .font(.system(size: 14))
                                                .foregroundColor(.coffeeSecondary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(Color.coffeeCream.opacity(0.6))
                                                )
                                        }
                                    }
                                }
                                
                                // 烘焙细节部分
                                if let roastingDetails = detail.roastingDetails {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("烘焙细节")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.coffeePrimary)
                                        
                                        RoastingDetailsView(roastingDetails: roastingDetails)
                                    }
                                    .padding(.vertical, 8)
                                } else {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("烘焙细节")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.coffeePrimary)
                                        
                                        Text("抱歉，暂时无法获取该咖啡的烘焙详情。")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red.opacity(0.8))
                                            .padding(.vertical, 8)
                                    }
                                    .padding(.vertical, 8)
                                }
                                
                                // 冲煮指南部分
                                if let brewingGuide = detail.brewingGuide {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("专业冲煮指南")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.coffeePrimary)
                                        
                                        BrewingGuideView(brewingGuide: brewingGuide)
                                    }
                                    .padding(.vertical, 8)
                                } else {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("专业冲煮指南")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.coffeePrimary)
                                        
                                        Text("抱歉，暂时无法获取该咖啡的冲煮指南。")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red.opacity(0.8))
                                            .padding(.vertical, 8)
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        } else {
                            VStack(spacing: 24) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.coffeeSecondary)
                                
                                Text("无法获取咖啡详情")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.coffeePrimary)
                                
                                Text("请检查您的网络连接后再试")
                                    .font(.system(size: 16))
                                    .foregroundColor(.coffeeSecondary)
                                
                                Button(action: {
                                    loadCoffeeDetail()
                                }) {
                                    Text("重试")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color.coffeeAccent)
                                        )
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 60)
                        }
                    }
                    .padding()
                    .padding(.top, 0) // 移除顶部边距，因为已经有导航栏了
                    .padding(.bottom, 30)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            // 先检查缓存
            if let cachedDetail = loadCachedCoffeeDetail(for: coffeeName) {
                coffeeDetail = cachedDetail
                isLoading = false
            } else {
                loadCoffeeDetail()
            }
        }
        .overlay(
            // 网络错误提示
            Group {
                if showNetworkError {
                    NetworkErrorView(
                        isShowing: $showNetworkError,
                        errorMessage: errorMessage,
                        retryAction: loadCoffeeDetail
                    )
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NetworkOfflineNotification"))) { _ in
            // 接收到网络离线通知时显示错误
            showNetworkErrorAlert()
        }
    }
    
    private func showNetworkErrorAlert() {
        withAnimation {
            showNetworkError = true
        }
        
        // 5秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                showNetworkError = false
            }
        }
    }
    
    private func loadCoffeeDetail() {
        isLoading = true
        print("🔍 开始加载咖啡详情: \(coffeeName)")
        
        // 首先检查是否有预加载的数据
        if let preloadedDetail = homeViewModel.getPreloadedDetail(for: coffeeName) {
            self.coffeeDetail = preloadedDetail
            isLoading = false
            print("✅ 使用预加载的详情数据: \(coffeeName)")
            print("📊 预加载缓存中的咖啡: \(homeViewModel.getPreloadedCoffeeNames().joined(separator: ", "))")
            return
        } else {
            print("❌ 未找到预加载数据: \(coffeeName)")
        }
        
        // 尝试加载缓存数据
        if let cachedDetail = loadCachedCoffeeDetail(for: coffeeName) {
            self.coffeeDetail = cachedDetail
            isLoading = false
            print("📦 使用缓存的详情数据: \(coffeeName)")
        } else {
            print("❌ 未找到缓存数据: \(coffeeName)")
        }
        
        // 无论是否有缓存，都请求新数据
        print("🚀 请求新的详情数据: \(coffeeName)")
        ZhipuAPIService.shared.fetchCoffeeDetail(coffeeName: coffeeName) { detail in
            DispatchQueue.main.async {
                self.isLoading = false
                if let detail = detail {
                    self.coffeeDetail = detail
                    // 缓存详情数据
                    self.cacheCoffeeDetail(detail, for: coffeeName)
                    print("✅ 成功获取新的详情数据: \(coffeeName)")
                } else if self.coffeeDetail == nil {
                    self.errorMessage = "无法获取咖啡详情，请检查网络连接或稍后再试。"
                    self.showNetworkError = true
                    print("❌ 获取详情数据失败: \(coffeeName)")
                }
            }
        }
    }
    
    // 缓存咖啡详情
    private func cacheCoffeeDetail(_ detail: CoffeeDetail, for name: String) {
        if let encoded = try? JSONEncoder().encode(detail) {
            UserDefaults.standard.set(encoded, forKey: "coffee_detail_\(name)")
        }
    }
    
    // 获取缓存的咖啡详情
    private func loadCachedCoffeeDetail(for name: String) -> CoffeeDetail? {
        if let data = UserDefaults.standard.data(forKey: "coffee_detail_\(name)"),
           let decoded = try? JSONDecoder().decode(CoffeeDetail.self, from: data) {
            return decoded
        }
        return nil
    }
    
    // 获取安全区域顶部高度的辅助函数
    private func getSafeAreaTop() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
            
        return keyWindow?.safeAreaInsets.top ?? 0
    }
}

// 详情页面的章节组件
struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.coffeePrimary)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.coffeeSecondary)
                .lineSpacing(4)
        }
    }
}

// 烘焙细节组件
struct RoastingDetailsView: View {
    let roastingDetails: RoastingDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 烘焙温度曲线示意图
            ZStack(alignment: .bottomLeading) {
                // 背景网格
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.coffeeLightBrown.opacity(0.2))
                    .frame(height: 160)
                
                // 温度曲线（简化示意）
                Path { path in
                    let width: CGFloat = UIScreen.main.bounds.width - 80
                    let height: CGFloat = 130
                    
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addCurve(
                        to: CGPoint(x: width * 0.4, y: height * 0.6),
                        control1: CGPoint(x: width * 0.1, y: height * 0.8),
                        control2: CGPoint(x: width * 0.3, y: height * 0.65)
                    )
                    path.addCurve(
                        to: CGPoint(x: width * 0.6, y: height * 0.3),
                        control1: CGPoint(x: width * 0.5, y: height * 0.5),
                        control2: CGPoint(x: width * 0.55, y: height * 0.4)
                    )
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.1),
                        control1: CGPoint(x: width * 0.7, y: height * 0.2),
                        control2: CGPoint(x: width * 0.9, y: height * 0.15)
                    )
                }
                .stroke(Color.coffeeAccent, lineWidth: 3)
                
                // 一爆标记
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 12, height: 12)
                    
                    Text("一爆")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red.opacity(0.7))
                        )
                        .offset(y: -20)
                }
                .position(x: UIScreen.main.bounds.width * 0.4 - 40, y: 160 * 0.6)
                
                // 二爆标记
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 12, height: 12)
                    
                    Text("二爆")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.7))
                        )
                        .offset(y: -20)
                }
                .position(x: UIScreen.main.bounds.width * 0.6 - 40, y: 160 * 0.3)
            }
            .padding(.bottom, 8)
            
            // 一爆信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 8, height: 8)
                    
                    Text("一爆时间：\(roastingDetails.firstCrackTime)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.coffeePrimary)
                }
                
                if !roastingDetails.roastingNotes.isEmpty {
                    Text(roastingDetails.roastingNotes)
                        .font(.system(size: 14))
                        .foregroundColor(.coffeeSecondary)
                        .padding(.leading, 16)
                }
            }
            
            // 二爆信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 8, height: 8)
                    
                    Text("二爆时间：\(roastingDetails.secondCrackTime)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.coffeePrimary)
                }
                
                if !roastingDetails.roastingCurve.isEmpty {
                    Text(roastingDetails.roastingCurve)
                        .font(.system(size: 14))
                        .foregroundColor(.coffeeSecondary)
                        .padding(.leading, 16)
                }
            }
            
            // 总烘焙时间
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总烘焙时间")
                        .font(.system(size: 14))
                        .foregroundColor(.coffeeSecondary)
                    
                    Text(roastingDetails.totalRoastTime)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.coffeePrimary)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.coffeeCream.opacity(0.3))
        )
    }
}

// 冲煮指南组件
struct BrewingGuideView: View {
    let brewingGuide: BrewingGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 基本参数
            HStack(spacing: 20) {
                BrewingParameterView(
                    icon: "scalemass",
                    title: "水粉比",
                    value: brewingGuide.coffeeToWaterRatio
                )
                
                BrewingParameterView(
                    icon: "thermometer",
                    title: "水温",
                    value: brewingGuide.waterTemperature
                )
                
                BrewingParameterView(
                    icon: "clock",
                    title: "总时间",
                    value: brewingGuide.totalBrewTime
                )
            }
            
            // 研磨度指示
            VStack(alignment: .leading, spacing: 8) {
                Text("研磨度")
                    .font(.system(size: 14))
                    .foregroundColor(.coffeeSecondary)
                
                Text(brewingGuide.groundSize)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.coffeePrimary)
            }
            .padding(.vertical, 4)
            
            // 冲煮步骤
            VStack(alignment: .leading, spacing: 12) {
                Text("冲煮步骤")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.coffeePrimary)
                
                ForEach(Array(brewingGuide.pourStages.enumerated()), id: \.offset) { index, stage in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(Color.coffeeAccent)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stage.stageName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.coffeePrimary)
                                
                            Text("水量: \(stage.waterAmount) • 注水: \(stage.pourTime) • 等待: \(stage.waitTime)")
                                .font(.system(size: 14))
                                .foregroundColor(.coffeeSecondary)
                                
                            if !stage.purpose.isEmpty {
                                Text(stage.purpose)
                                    .font(.system(size: 13))
                                    .foregroundColor(.coffeeSecondary.opacity(0.8))
                                    .italic()
                            }
                        }
                    }
                    .padding(.bottom, 4)
                }
                
                if !brewingGuide.specialNotes.isEmpty {
                    Text(brewingGuide.specialNotes)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.coffeeSecondary)
                        .padding(.top, 8)
                        .padding(.leading, 8)
                        .italic()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.coffeeCream.opacity(0.3))
        )
    }
}

// 冲煮参数组件
struct BrewingParameterView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.coffeeAccent)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.coffeeSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.coffeePrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

