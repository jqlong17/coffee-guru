import Foundation
import SwiftUI

/// 咖啡预加载服务
/// 负责管理咖啡详情的预加载逻辑
class CoffeePreloadService {
    // MARK: - 单例
    
    static let shared = CoffeePreloadService()
    
    // MARK: - 属性
    
    /// 预加载的咖啡详情缓存
    private var preloadedDetails: [String: CoffeeDetail] = [:]
    
    /// 当前可见的卡片索引集合
    private var visibleCardIndices: Set<Int> = []
    
    /// 是否正在预加载
    private var isPreloading = false
    
    /// 预加载防抖间隔
    private let preloadDebounceInterval: TimeInterval = 0.5
    
    /// 预加载工作项
    private var preloadWorkItem: DispatchWorkItem?
    
    /// 最后滚动时间
    private var lastScrollTime: Date?
    
    /// 滚动稳定阈值（秒）
    private let scrollStableThreshold: TimeInterval = 2.0
    
    /// 滚动稳定检查定时器
    private var stableCheckTimer: Timer?
    
    /// 当前咖啡列表
    private var coffeeItems: [CoffeeItem] = []
    
    // MARK: - 初始化方法
    
    private init() {}
    
    // MARK: - 公共方法
    
    /// 更新咖啡列表
    /// - Parameter items: 咖啡列表
    func updateCoffeeItems(_ items: [CoffeeItem]) {
        coffeeItems = items
    }
    
    /// 卡片出现在视图中
    /// - Parameter index: 卡片索引
    func cardAppeared(at index: Int) {
        // 更新最后滚动时间
        lastScrollTime = Date()
        
        // 将新出现的卡片索引添加到可见卡片集合中
        visibleCardIndices.insert(index)
        
        // 检查索引是否有效
        guard index >= 0, !coffeeItems.isEmpty else { return }
        
        if index >= coffeeItems.count {
            print("⚠️ 无效的卡片索引: \(index), 咖啡列表大小: \(coffeeItems.count)")
            return
        }
        
        // 取消之前的预加载任务和定时器
        preloadWorkItem?.cancel()
        stableCheckTimer?.invalidate()
        
        // 创建新的预加载任务
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // 打印当前所有可见的卡片索引
            print("🔍 当前可见卡片索引: \(self.visibleCardIndices.sorted())")
            
            // 创建一个定时器来检查滚动是否稳定
            self.stableCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                guard let self = self,
                      let lastScroll = self.lastScrollTime else {
                    timer.invalidate()
                    return
                }
                
                // 检查是否已经停止滚动足够长的时间
                let stableTime = Date().timeIntervalSince(lastScroll)
                if stableTime >= self.scrollStableThreshold {
                    // 停止定时器
                    timer.invalidate()
                    // 执行预加载
                    print("⏱️ 滚动稳定 \(String(format: "%.1f", stableTime))秒，开始预加载")
                    self.preloadVisibleCardDetails()
                }
            }
        }
        
        preloadWorkItem = workItem
        
        // 延迟执行预加载检查
        DispatchQueue.main.asyncAfter(deadline: .now() + preloadDebounceInterval, execute: workItem)
    }
    
    /// 卡片从视图中消失
    /// - Parameter index: 卡片索引
    func cardDisappeared(at index: Int) {
        visibleCardIndices.remove(index)
        print("🔍 卡片已从可见集合中移除 [索引: \(index)], 当前可见卡片: \(visibleCardIndices.sorted())")
    }
    
    /// 获取预加载的咖啡详情
    /// - Parameter coffeeName: 咖啡名称
    /// - Returns: 咖啡详情，如果未预加载则返回 nil
    func getPreloadedDetail(for coffeeName: String) -> CoffeeDetail? {
        return preloadedDetails[coffeeName]
    }
    
    /// 获取所有预加载的咖啡名称
    /// - Returns: 预加载的咖啡名称数组
    func getPreloadedCoffeeNames() -> [String] {
        return Array(preloadedDetails.keys)
    }
    
    /// 清除预加载的详情数据
    func clearPreloadedDetails() {
        preloadedDetails.removeAll()
        visibleCardIndices.removeAll()
        
        // 清理定时器
        stableCheckTimer?.invalidate()
        stableCheckTimer = nil
        
        // 取消预加载任务
        preloadWorkItem?.cancel()
        preloadWorkItem = nil
        
        isPreloading = false
    }
    
    /// 处理内存警告
    func handleMemoryWarning() {
        clearPreloadedDetails()
    }
    
    // MARK: - 私有方法
    
    /// 预加载可见卡片的详情
    private func preloadVisibleCardDetails() {
        guard !isPreloading,
              !visibleCardIndices.isEmpty,
              !coffeeItems.isEmpty else {
            print("❌ 预加载取消: 已在加载中或没有可见卡片或咖啡列表为空")
            return
        }
        
        // 打印当前可见的所有咖啡
        print("📋 当前可见范围内的咖啡:")
        for i in visibleCardIndices.sorted() where i < coffeeItems.count {
            print("  - [\(i)] \(coffeeItems[i].name)")
        }
        
        // 获取第一个可见卡片的索引
        if let firstVisibleIndex = visibleCardIndices.sorted().first, firstVisibleIndex < coffeeItems.count {
            // 预加载第一个可见卡片
            print("🚀 开始预加载咖啡详情: \(coffeeItems[firstVisibleIndex].name) [索引: \(firstVisibleIndex)]")
            preloadCardDetail(at: firstVisibleIndex)
            
            // 如果有第二个可见卡片，也预加载它
            let sortedIndices = visibleCardIndices.sorted()
            if sortedIndices.count > 1, let secondVisibleIndex = sortedIndices[safe: 1], secondVisibleIndex < coffeeItems.count {
                // 延迟500毫秒预加载第二个卡片，避免同时发起两个请求
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    print("🚀 开始预加载咖啡详情: \(self.coffeeItems[secondVisibleIndex].name) [索引: \(secondVisibleIndex)]")
                    self.preloadCardDetail(at: secondVisibleIndex)
                }
            }
        }
    }
    
    /// 预加载指定索引的卡片详情
    private func preloadCardDetail(at index: Int) {
        guard index < coffeeItems.count, !isPreloading else {
            return
        }
        
        let coffeeItem = coffeeItems[index]
        
        // 检查是否已经预加载
        if preloadedDetails[coffeeItem.name] != nil {
            print("✅ 已存在预加载数据: \(coffeeItem.name) [索引: \(index)]")
            return
        }
        
        isPreloading = true
        
        // 记录预加载开始时间
        let preloadStartTime = Date()
        let requestID = UUID().uuidString.prefix(8)
        print("🔄 开始预加载请求: \(coffeeItem.name) [索引: \(index)], 请求ID: \(requestID)")
        
        ZhipuAPIService.shared.fetchCoffeeDetail(coffeeName: coffeeItem.name) { [weak self] detail in
            guard let self = self else { return }
            
            // 计算预加载总时长
            let preloadEndTime = Date()
            let timeInterval = preloadEndTime.timeIntervalSince(preloadStartTime)
            
            DispatchQueue.main.async {
                self.isPreloading = false
                if let detail = detail {
                    self.preloadedDetails[coffeeItem.name] = detail
                    print("✅ 成功预加载咖啡详情: \(coffeeItem.name) [索引: \(index)], 总时长: \(String(format: "%.2f", timeInterval))秒")
                    print("📊 当前预加载缓存: \(self.preloadedDetails.keys.joined(separator: ", "))")
                } else {
                    print("❌ 预加载失败: \(coffeeItem.name) [索引: \(index)], 耗时: \(String(format: "%.2f", timeInterval))秒")
                }
            }
        }
    }
}

// MARK: - 数组扩展
extension Array {
    /// 安全地访问数组元素，如果索引越界则返回 nil
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 