import SwiftUI
import Combine
import Foundation
import UIKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 提取主内容为子视图，简化主体视图层级
                HomeMainContent(viewModel: viewModel)
                
                // 启动画面
                if viewModel.showSplash {
                    HomeViewSplash(isShowing: $viewModel.showSplash)
                }
                
                // 网络错误提示
                if viewModel.showNetworkError {
                    NetworkErrorView(
                        isShowing: $viewModel.showNetworkError,
                        errorMessage: viewModel.errorMessage,
                        retryAction: viewModel.retryLoading
                    )
                }
            }
            .navigationTitle("咖啡大师")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NetworkOfflineNotification"))) { _ in
            // 这个通知接收已经移至ViewModel，但为了兼容性保留
        }
        // 添加内存警告处理
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            viewModel.handleMemoryWarning()
        }
    }
}

// 提取主内容为单独的结构体，减轻编译器负担
struct HomeMainContent: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 主内容
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if let featuredCoffee = viewModel.featuredCoffee {
                            FeaturedCoffeeView(
                                featuredCoffee: featuredCoffee,
                                isLoadingData: viewModel.isLoadingData
                            )
                                .padding(.horizontal)
                        }
                        
                        // 咖啡卡片标题
                        HStack {
                            Text("精选咖啡")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(CoffeeGuru.Theme.Colors.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // 双列网格布局
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(Array(viewModel.coffeeItems.enumerated()), id: \.element.id) { index, coffee in
                                CoffeeCard(coffee: coffee)
                                    // 添加出现检测
                                    .id("coffee-card-\(index)")  // 添加唯一ID以便跟踪
                                    .onAppear {
                                        print("☑️ 卡片出现在视图中: \(coffee.name) [索引: \(index)]")
                                        
                                        // 通知预加载服务卡片出现
                                        viewModel.updateVisibleCards(
                                            startIndex: index,
                                            endIndex: index + 1
                                        )
                                        
                                        // 检查是否需要加载更多
                                        if index == viewModel.coffeeItems.count - 2 {
                                            viewModel.loadMoreCoffee()
                                        }
                                    }
                                    .onDisappear {
                                        print("❎ 卡片离开视图: \(coffee.name) [索引: \(index)]")
                                        
                                        // 通知预加载服务卡片消失
                                        DispatchQueue.main.async {
                                            viewModel.removeVisibleCard(at: index)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.showLoadMoreButton {
                            Button(action: {
                                viewModel.loadMoreCoffee()
                            }) {
                                Text("加载更多")
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            .disabled(viewModel.isLoadingMore)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    // 刷新时清除预加载的数据
                    viewModel.clearPreloadedDetails()
                    viewModel.retryLoading()
                }
            }
            .navigationBarHidden(true)
            .background(CoffeeGuru.Theme.Colors.background)
            .onAppear {
                // 检查是否需要加载精选咖啡
                if viewModel.featuredCoffee == nil || viewModel.isCacheExpired() {
                    viewModel.loadFeaturedCoffee()
                }
                
                // 检查是否需要加载咖啡列表
                if viewModel.coffeeItems.isEmpty || viewModel.isCacheExpired() {
                    viewModel.loadCoffeeData(loadMore: false)
                }
            }
            // 添加导航目的地处理
            .navigationDestination(for: String.self) { coffeeName in
                CoffeeDetailView(coffeeName: coffeeName)
                    .environmentObject(viewModel)  // 传递 HomeViewModel
            }
        }
    }
}

// 标题区域视图
struct TitleSectionView: View {
    @Binding var isLoading: Bool
    @State private var showClearAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: CoffeeGuru.Dimensions.Padding.small) {
                Text("咖啡大师")
                    .font(.system(size: CoffeeGuru.Dimensions.FontSize.title, weight: .bold))
                    .foregroundColor(CoffeeGuru.Theme.Colors.primary)
                
                Text("探索精品咖啡的世界")
                    .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                    .foregroundColor(CoffeeGuru.Theme.Colors.secondary)
            }
            .onLongPressGesture {
                // 显示清除记录的确认对话框
                showClearAlert = true
            }
            .alert("清除咖啡记录", isPresented: $showClearAlert) {
                Button("取消", role: .cancel) {}
                Button("清除", role: .destructive) {
                    // 清除所有已记录的咖啡名称
                    ZhipuAPIService.shared.clearReturnedCoffeeNames()
                }
            } message: {
                Text("这将清除所有已记录的咖啡名称，以便获取全新的咖啡数据。确定要继续吗？")
            }
            
            Spacer()
            
            Image(systemName: "mug.fill")
                .font(.system(size: CoffeeGuru.Dimensions.Icon.large - 2))
                .foregroundColor(CoffeeGuru.Theme.Colors.accent)
                .padding(CoffeeGuru.Dimensions.Padding.medium)
                .background(
                    Circle()
                        .fill(CoffeeGuru.Theme.Colors.cardBackground)
                        .shadow(
                            color: CoffeeGuru.Style.Shadow.light.color,
                            radius: CoffeeGuru.Style.Shadow.light.radius,
                            x: CoffeeGuru.Style.Shadow.light.x,
                            y: CoffeeGuru.Style.Shadow.light.y
                        )
                )
        }
        .padding(.vertical, CoffeeGuru.Dimensions.Padding.medium)
    }
}

// 咖啡卡片标题视图
struct CoffeeCardsTitleView: View {
    var body: some View {
        HStack {
            Text("精选咖啡")
                .font(.system(size: CoffeeGuru.Dimensions.FontSize.subtitle, weight: .bold))
                .foregroundColor(CoffeeGuru.Theme.Colors.primary)
            
            Spacer()
        }
    }
}

// 咖啡卡片网格视图
struct CoffeeCardsGridView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        if viewModel.isLoadingData && viewModel.coffeeItems.isEmpty {
            HStack {
                Spacer()
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CoffeeGuru.Theme.Colors.primary))
                        .scaleEffect(1.2)
                    
                    Text("加载中...")
                        .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                        .foregroundColor(CoffeeGuru.Theme.Colors.secondary)
                        .padding(.top, CoffeeGuru.Dimensions.Padding.medium)
                }
                Spacer()
            }
            .padding(.vertical, CoffeeGuru.Dimensions.Padding.extraLarge + 16)
        } else if viewModel.coffeeItems.isEmpty {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: CoffeeGuru.Dimensions.Icon.large + 8))
                        .foregroundColor(CoffeeGuru.Theme.Colors.lightBrown)
                    Text("暂无咖啡数据")
                        .font(.system(size: CoffeeGuru.Dimensions.FontSize.body + 2, weight: .medium))
                        .foregroundColor(CoffeeGuru.Theme.Colors.secondary)
                        .padding(.top, CoffeeGuru.Dimensions.Padding.medium)
                    Button(action: {
                        viewModel.loadCoffeeData(loadMore: false)
                    }) {
                        Text("点击刷新")
                            .font(.system(size: CoffeeGuru.Dimensions.FontSize.body))
                            .foregroundColor(CoffeeGuru.Theme.Colors.textLight)
                            .padding(.horizontal, CoffeeGuru.Dimensions.Padding.large)
                            .padding(.vertical, CoffeeGuru.Dimensions.Padding.medium)
                            .background(
                                RoundedRectangle(cornerRadius: CoffeeGuru.Style.CornerRadius.standard)
                                    .fill(CoffeeGuru.Theme.Colors.accent)
                            )
                    }
                    .padding(.top, CoffeeGuru.Dimensions.Padding.medium)
                }
                Spacer()
            }
            .padding(.vertical, CoffeeGuru.Dimensions.Padding.extraLarge + 16)
        } else {
            VStack {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CoffeeGuru.Dimensions.Padding.large) {
                    ForEach(Array(viewModel.coffeeItems.enumerated()), id: \.element.id) { index, item in
                        CoffeeCard(coffee: item)
                            .transition(.scale)
                            .onAppear {
                                // 当显示到倒数第3个卡片时触发预加载
                                if index >= viewModel.coffeeItems.count - 3 && !viewModel.isLoadingMore && !viewModel.isLoadingData && viewModel.showLoadMoreButton {
                                    print("预加载触发：显示到第\(index+1)个卡片，共\(viewModel.coffeeItems.count)个")
                                    viewModel.loadMoreCoffee()
                                }
                            }
                    }
                    
                    // 在网格末尾添加加载指示器
                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: CoffeeGuru.Theme.Colors.primary))
                                .scaleEffect(1.2)
                            Spacer()
                        }
                        .frame(height: 60)
                        .gridCellColumns(2)
                    }
                }
                .padding(.vertical, CoffeeGuru.Dimensions.Padding.medium)
                
                // 移除底部检测区域，改为在卡片中检测
            }
            .onAppear {
                // 当视图出现时，显示加载更多按钮
                viewModel.showLoadMoreButton = true
            }
        }
    }
}

// 用于检测滚动位置的PreferenceKey
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 