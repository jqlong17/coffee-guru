import SwiftUI
import Combine
import Foundation

// 首页视图模型
class HomeViewModel: ObservableObject {
    // MARK: - 发布的状态属性
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showSplash = true
    @Published var coffeeItems: [CoffeeItem] = []
    @Published var featuredCoffee: CoffeeItem?
    @Published var isLoadingData = false
    @Published var isLoadingMore = false
    @Published var showNetworkError = false
    @Published var errorMessage = "网络连接错误，请检查您的网络设置。"
    @Published var showLoadMoreButton = false
    
    // MARK: - 私有属性
    private var cancellables = Set<AnyCancellable>()
    private var isLoadingCancellable: AnyCancellable?
    private var loadMoreDebounceTimer: Timer?
    private var lastLoadMoreTime: Date? = nil // 添加上次加载时间记录
    private let minLoadMoreInterval: TimeInterval = 3.0 // 最小加载间隔（秒）
    private var currentRequestId: UUID? = nil // 当前请求的唯一标识符
    private var pendingRequests: [UUID: Bool] = [:] // 记录所有进行中的请求及其loadMore状态
    
    // MARK: - 预加载相关属性
    private let preloadService = CoffeePreloadService.shared
    
    // MARK: - 初始化方法
    init() {
        // 监听网络离线状态变化
        NotificationCenter.default.publisher(for: Notification.Name("NetworkOfflineNotification"))
            .sink { [weak self] _ in
                self?.showNetworkErrorAlert()
            }
            .store(in: &cancellables)
        
        // 监听网络恢复状态变化
        NotificationCenter.default.publisher(for: Notification.Name("NetworkOnlineNotification"))
            .sink { [weak self] _ in
                print("网络已恢复，尝试刷新数据")
                // 网络恢复时，如果数据为空或过期，尝试刷新数据
                if let self = self, (self.coffeeItems.isEmpty || self.isCacheExpired()) {
                    self.retryLoading()
                }
            }
            .store(in: &cancellables)
            
        // 启动时设置一些默认值
        setupDefaultValues()
        
        // 添加加载状态的组合监听
        setupPublishers()
    }
    
    // 设置初始默认值
    private func setupDefaultValues() {
        // 显示加载更多按钮默认为true
        showLoadMoreButton = true
        
        // 设置咖啡杯图标的动画效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                self.isLoading = true
            }
        }
        
        // 延迟2秒后隐藏启动画面
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.5)) {
                self.showSplash = false
            }
        }
    }
    
    // 设置发布者监听
    private func setupPublishers() {
        // 监听isLoadingData和isLoadingMore的变化，确保状态一致性
        isLoadingCancellable = Publishers.CombineLatest($isLoadingData, $isLoadingMore)
            .map { isLoadingData, isLoadingMore in
                return isLoadingData || isLoadingMore
            }
            .receive(on: RunLoop.main)
            .sink { isLoading in
                // 可以在这里添加全局加载状态的处理逻辑
                print("全局加载状态变更: \(isLoading)")
            }
    }
    
    // MARK: - 公共方法
    
    /// 尝试重新加载数据
    func retryLoading() {
        loadFeaturedCoffee()
        loadCoffeeData(loadMore: false)
    }
    
    /// 加载更多咖啡数据
    func loadMoreCoffee() {
        // 如果已经在加载中，则忽略此次请求
        guard !isLoadingMore && !isLoadingData else {
            print("已有加载任务进行中，忽略加载更多请求")
            return
        }
        
        // 添加防抖动逻辑，避免短时间内多次触发
        if let lastTime = lastLoadMoreTime, Date().timeIntervalSince(lastTime) < minLoadMoreInterval {
            print("加载间隔过短，忽略此次请求，距离上次加载: \(Date().timeIntervalSince(lastTime))秒")
            return
        }
        
        print("触发加载更多咖啡 - 当前状态: isLoadingMore=\(isLoadingMore), isLoadingData=\(isLoadingData)")
        
        // 更新最后加载时间
        lastLoadMoreTime = Date()
        
        // 设置加载状态
        isLoadingMore = true
        
        // 加载更多数据
        loadCoffeeData(loadMore: true)
    }
    
    /// 加载咖啡数据
    func loadCoffeeData(loadMore: Bool = false) {
        // 如果是刷新（非加载更多），则设置isLoadingData为true
        if !loadMore {
            isLoadingData = true
        } else {
            isLoadingMore = true
        }
        
        // 计算offset
        let offset = loadMore ? coffeeItems.count : 0
        
        print("开始加载咖啡数据 - 加载更多: \(loadMore), 当前数量: \(coffeeItems.count), offset: \(offset)")
        
        // 检查缓存
        if let cachedData = loadCachedCoffeeData(),
           !cachedData.isEmpty {
            // 先使用缓存数据并停止加载状态
            if !loadMore {
                self.coffeeItems = cachedData
                print("使用缓存数据，数量: \(cachedData.count)")
                isLoadingData = false
                
                // 更新预加载服务中的咖啡列表
                preloadService.updateCoffeeItems(cachedData)
            } else {
                // 如果是加载更多但没有更多缓存数据，则从API获取
                if cachedData.count <= offset {
                    print("缓存中没有更多数据，尝试从API获取")
                } else {
                    // 如果缓存中有更多数据，使用缓存中的额外数据
                    let additionalItems = Array(cachedData[offset...])
                    if !additionalItems.isEmpty {
                        print("从缓存中加载更多数据，数量: \(additionalItems.count)")
                        DispatchQueue.main.async {
                            self.coffeeItems.append(contentsOf: additionalItems)
                            self.isLoadingMore = false
                            
                            // 更新预加载服务中的咖啡列表
                            self.preloadService.updateCoffeeItems(self.coffeeItems)
                        }
                        return
                    }
                }
            }
            
            // 检查缓存是否过期（30分钟）
            if !isCacheExpired() && !loadMore {
                // 如果缓存有效且不是加载更多，不请求API
                print("缓存有效，不请求API")
                return
            }
        }
        
        // 生成新的请求ID
        let requestId = UUID()
        currentRequestId = requestId
        pendingRequests[requestId] = loadMore
        
        print("创建API请求 - ID: \(requestId), 加载更多: \(loadMore)")
        
        // 调用API获取数据
        ZhipuAPIService.shared.fetchCoffeeData(offset: offset) { [weak self] items in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // 检查这个请求是否仍然有效
                guard let isLoadingMore = self.pendingRequests[requestId] else {
                    print("请求已取消或无效 - ID: \(requestId)")
                    return
                }
                
                // 移除已处理的请求
                self.pendingRequests.removeValue(forKey: requestId)
                
                // 如果这不是最新的请求，且是加载更多操作，仍然处理结果
                // 如果是刷新操作，则只有最新的请求才会被处理
                if requestId != self.currentRequestId && !isLoadingMore {
                    print("忽略旧的刷新请求 - ID: \(requestId), 当前ID: \(String(describing: self.currentRequestId))")
                    return
                }
                
                // 根据加载模式设置相应的加载状态为false
                if isLoadingMore {
                    self.isLoadingMore = false
                } else {
                    self.isLoadingData = false
                }
                
                print("处理API返回数据 - ID: \(requestId), 加载更多: \(isLoadingMore), 返回数量: \(items.count)")
                
                if items.isEmpty {
                    // 如果API返回空数据
                    print("API返回空数据")
                    // 加载更多时如果没有更多数据，设置标志位
                    if isLoadingMore {
                        self.showLoadMoreButton = false
                        print("没有更多数据，隐藏加载更多按钮")
                    }
                } else {
                    if isLoadingMore {
                        // 加载更多时，将新数据添加到现有数据后面
                        let oldCount = self.coffeeItems.count
                        self.coffeeItems.append(contentsOf: items)
                        print("加载更多成功 - 原有数量: \(oldCount), 新增数量: \(items.count), 总数量: \(self.coffeeItems.count)")
                        
                        // 确保按钮仍然显示，因为可能有更多数据
                        self.showLoadMoreButton = true
                    } else {
                        // 刷新时，替换现有数据
                        self.coffeeItems = items
                        print("刷新数据成功 - 新数据数量: \(items.count)")
                        
                        // 刷新成功后显示加载更多按钮
                        self.showLoadMoreButton = true
                    }
                    
                    // 更新预加载服务中的咖啡列表
                    self.preloadService.updateCoffeeItems(self.coffeeItems)
                    
                    // 缓存数据和缓存时间
                    self.cacheCoffeeData(self.coffeeItems)
                    UserDefaults.standard.set(Date(), forKey: "coffee_time")
                }
            }
        }
    }
    
    /// 加载精选咖啡
    func loadFeaturedCoffee() {
        isLoadingData = true
        
        // 检查缓存
        if let cachedCoffee = loadCachedFeaturedCoffee() {
            // 先使用缓存数据
            self.featuredCoffee = cachedCoffee
            isLoadingData = false
            
            // 检查缓存是否当天有效
            if !isCacheExpired() {
                // 如果缓存有效，不请求API
                return
            }
        }
        
        ZhipuAPIService.shared.fetchFeaturedCoffee { [weak self] coffee in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoadingData = false
                if let coffee = coffee {
                    self.featuredCoffee = coffee
                    // 缓存数据
                    self.cacheFeaturedCoffee(coffee)
                } else if self.featuredCoffee == nil {
                    // 如果API失败且没有缓存，显示错误信息
                    print("无法获取精选咖啡数据")
                    // 不再使用默认数据
                }
            }
        }
    }
    
    // MARK: - 预加载相关方法
    
    /// 更新可见卡片范围并触发预加载
    func updateVisibleCards(startIndex: Int, endIndex: Int) {
        preloadService.cardAppeared(at: startIndex)
    }
    
    /// 从可见卡片集合中移除指定索引的卡片
    func removeVisibleCard(at index: Int) {
        preloadService.cardDisappeared(at: index)
    }
    
    /// 获取预加载的咖啡详情
    func getPreloadedDetail(for coffeeName: String) -> CoffeeDetail? {
        return preloadService.getPreloadedDetail(for: coffeeName)
    }
    
    /// 获取所有预加载的咖啡名称
    func getPreloadedCoffeeNames() -> [String] {
        return preloadService.getPreloadedCoffeeNames()
    }
    
    /// 清除预加载的详情数据
    func clearPreloadedDetails() {
        preloadService.clearPreloadedDetails()
    }
    
    // 当内存警告时清理预加载数据
    func handleMemoryWarning() {
        preloadService.handleMemoryWarning()
    }
    
    // MARK: - 私有辅助方法
    
    /// 显示网络错误提示
    private func showNetworkErrorAlert() {
        withAnimation {
            showNetworkError = true
        }
        
        // 5秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                self.showNetworkError = false
            }
        }
    }
    
    /// 检查缓存是否过期
    func isCacheExpired() -> Bool {
        if let cacheTime = UserDefaults.standard.object(forKey: "coffee_time") as? Date {
            // 定义缓存有效期为30分钟
            let cacheValidDuration: TimeInterval = 30 * 60
            return Date().timeIntervalSince(cacheTime) > cacheValidDuration
        }
        return true // 如果没有缓存时间，认为缓存已过期
    }
    
    /// 缓存咖啡数据
    private func cacheCoffeeData(_ items: [CoffeeItem], _ key: String = "coffee") {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "coffee_data")
        }
    }
    
    /// 加载缓存的咖啡数据
    func loadCachedCoffeeData(_ key: String = "coffee") -> [CoffeeItem]? {
        if let data = UserDefaults.standard.data(forKey: "coffee_data"),
           let decoded = try? JSONDecoder().decode([CoffeeItem].self, from: data) {
            return decoded
        }
        return nil
    }
    
    /// 缓存精选咖啡
    private func cacheFeaturedCoffee(_ coffee: CoffeeItem) {
        if let encoded = try? JSONEncoder().encode(coffee) {
            UserDefaults.standard.set(encoded, forKey: "featured_coffee")
            UserDefaults.standard.set(Date(), forKey: "featured_coffee_date")
        }
    }
    
    /// 加载缓存的精选咖啡
    private func loadCachedFeaturedCoffee() -> CoffeeItem? {
        // 获取精选咖啡缓存
        if let data = UserDefaults.standard.data(forKey: "featured_coffee"),
           let decoded = try? JSONDecoder().decode(CoffeeItem.self, from: data) {
            return decoded
        }
        return nil
    }
    
    // MARK: - 析构函数
    deinit {
        // 取消所有订阅和计时器
        cancellables.forEach { $0.cancel() }
        isLoadingCancellable?.cancel()
        loadMoreDebounceTimer?.invalidate()
        pendingRequests.removeAll()
        print("HomeViewModel 被释放")
    }
} 