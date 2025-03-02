import Foundation
import SwiftUI  // 如果需要 UI 相关功能
// 不需要导入 Prompts 模块，因为它在同一个项目中

// 咖啡业务API服务
class ZhipuAPIService {
    static let shared = ZhipuAPIService()
    
    // 记录已返回的咖啡名称
    private var returnedCoffeeNames: Set<String> = []
    // 记录已返回的精选咖啡名称
    private var returnedFeaturedCoffeeNames: Set<String> = []
    
    // 添加请求ID管理
    private var activeDetailRequests: [String: UUID] = [:]
    private var pendingDetailCallbacks: [UUID: [(CoffeeDetail?) -> Void]] = [:]
    
    // 响应解析器
    private let responseParser = ZhipuResponseParser.shared
    
    // 数据存储管理器
    private let dataStore = CoffeeDataStore.shared
    
    private init() {
        // 从数据存储加载已返回的咖啡名称
        loadReturnedCoffeeNames()
    }
    
    // 从数据存储加载已返回的咖啡名称
    private func loadReturnedCoffeeNames() {
        // 加载咖啡名称
        returnedCoffeeNames = dataStore.loadReturnedCoffeeNames()
        
        // 加载精选咖啡名称
        returnedFeaturedCoffeeNames = dataStore.loadReturnedFeaturedCoffeeNames()
    }
    
    // 保存已返回的咖啡名称到数据存储
    private func saveReturnedCoffeeNames() {
        // 保存咖啡名称
        dataStore.saveReturnedCoffeeNames(returnedCoffeeNames)
        
        // 保存精选咖啡名称
        dataStore.saveReturnedFeaturedCoffeeNames(returnedFeaturedCoffeeNames)
    }
    
    // 清除已记录的咖啡名称
    func clearReturnedCoffeeNames() {
        // 清除所有咖啡名称
        returnedCoffeeNames = []
        returnedFeaturedCoffeeNames = []
        
        // 清除数据存储中的记录
        dataStore.clearAllCoffeeNames()
        
        print("已清除咖啡名称记录")
    }
    
    // 获取咖啡数据方法
    func fetchCoffeeData(offset: Int = 0, completion: @escaping ([CoffeeItem]) -> Void) {
        // 获取已返回的咖啡名称
        let existingNames = returnedCoffeeNames.isEmpty ? "无" : Array(returnedCoffeeNames).joined(separator: "、")
        
        print("API请求咖啡数据 - offset: \(offset), 已有名称数量: \(returnedCoffeeNames.count)")
        
        // 使用 ZhipuPrompts 获取提示文本
        let prompt = ZhipuPrompts.coffeeListPrompt(offset: offset, existingNames: existingNames)
        
        // 调用API并处理响应
        ZhipuNetworkManager.shared.callZhipuAPI(prompt: prompt) { result in
            switch result {
            case .success(let jsonString):
                // 打印原始响应用于调试
                print("咖啡数据原始响应: \(jsonString.prefix(100))...")
                
                do {
                    // 使用响应解析器提取有效的 JSON
                    let extractedJSON = try self.responseParser.extractJSONString(from: jsonString)
                    print("提取后的JSON: \(extractedJSON.prefix(100))...")
                    
                    guard let jsonData = extractedJSON.data(using: .utf8) else {
                        print("无法将字符串转换为数据")
                        DispatchQueue.main.async { completion([]) }
                        return
                    }
                    
                    // 使用响应解析器解析咖啡列表
                    let coffeeItems = try self.responseParser.parseCoffeeItems(jsonData: jsonData)
                    
                    // 记录咖啡名称
                    for item in coffeeItems {
                        self.returnedCoffeeNames.insert(item.name)
                    }
                    
                    // 保存更新后的咖啡名称记录
                    self.saveReturnedCoffeeNames()
                    
                    print("处理完成，返回咖啡项数量: \(coffeeItems.count)")
                    DispatchQueue.main.async { completion(coffeeItems) }
                } catch {
                    print("获取咖啡数据失败: \(error)")
                    print("JSON解析错误，返回空数组")
                    // 解析失败时返回空数组
                    DispatchQueue.main.async { completion([]) }
                }
                
            case .failure(let error):
                print("获取咖啡数据失败: \(error)")
                
                // 处理不同类型的错误
                if let apiError = error as? ZhipuAPIError {
                    switch apiError {
                    case .networkOffline:
                        self.handleNetworkOfflineError()
                    default:
                        break
                    }
                }
                
                // 返回空数组
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
    
    // 获取精选咖啡方法
    func fetchFeaturedCoffee(completion: @escaping (CoffeeItem?) -> Void) {
        // 获取已返回的精选咖啡名称
        let namesString = returnedFeaturedCoffeeNames.isEmpty ? "无" : Array(returnedFeaturedCoffeeNames).joined(separator: "、")
        
        // 使用 ZhipuPrompts 获取提示文本
        let prompt = ZhipuPrompts.featuredCoffeePrompt(namesString: namesString)
        
        // 调用API并处理响应
        let modelParameters: [String: Any] = [
            "temperature": 0.8,   // 增加随机性
            "top_p": 0.9          // 增加多样性
        ]
        
        ZhipuNetworkManager.shared.callZhipuAPI(prompt: prompt, parameters: modelParameters) { result in
            switch result {
            case .success(let jsonString):
                // 打印原始响应
                print("精选咖啡原始响应: \(jsonString)")
                
                do {
                    // 使用响应解析器提取有效的 JSON
                    let extractedJSON = try self.responseParser.extractJSONString(from: jsonString)
                    print("提取后的JSON: \(extractedJSON)")
                    
                    guard let jsonData = extractedJSON.data(using: .utf8) else {
                        print("无法将字符串转换为数据")
                        DispatchQueue.main.async { completion(nil) }
                        return
                    }
                    
                    // 使用响应解析器解析精选咖啡
                    let featuredCoffee = try self.responseParser.parseFeaturedCoffee(jsonData: jsonData)
                    
                    // 记录精选咖啡名称
                    self.returnedFeaturedCoffeeNames.insert(featuredCoffee.name)
                    
                    // 保存更新后的咖啡名称记录
                    self.saveReturnedCoffeeNames()
                    
                    DispatchQueue.main.async { completion(featuredCoffee) }
                } catch {
                    print("获取精选咖啡失败: \(error)")
                    DispatchQueue.main.async { completion(nil) }
                }
                
            case .failure(let error):
                print("获取精选咖啡失败: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    // 获取咖啡详情方法 - 添加请求ID管理
    func fetchCoffeeDetail(coffeeName: String, completion: @escaping (CoffeeDetail?) -> Void) {
        print("🔍 请求咖啡详情: \(coffeeName)")
        
        // 检查是否已有相同咖啡名称的请求正在进行中
        if let existingRequestId = activeDetailRequests[coffeeName] {
            print("⚠️ 已有相同咖啡的请求正在进行中: \(coffeeName), 请求ID: \(existingRequestId)")
            
            // 将新的回调添加到待处理列表
            pendingDetailCallbacks[existingRequestId, default: []].append(completion)
            return
        }
        
        // 创建新的请求ID
        let requestId = UUID()
        activeDetailRequests[coffeeName] = requestId
        pendingDetailCallbacks[requestId] = [completion]
        
        print("📝 创建新的咖啡详情请求: \(coffeeName), 请求ID: \(requestId)")
        
        // 使用 ZhipuPrompts 获取提示文本
        let prompt = ZhipuPrompts.coffeeDetailPrompt(coffeeName: coffeeName)
        
        // 调用API并处理响应
        let modelParameters: [String: Any] = [
            "temperature": 0.7,   // 保持一定的创意性
            "top_p": 0.9,         // 增加多样性
            "max_tokens": 2000    // 增加回复长度限制，确保能返回详细内容
        ]
        
        ZhipuNetworkManager.shared.callZhipuAPI(prompt: prompt, parameters: modelParameters) { [weak self] result in
            guard let self = self else { return }
            
            // 获取当前请求的回调列表
            guard let callbacks = self.pendingDetailCallbacks[requestId] else {
                print("❌ 未找到请求ID对应的回调: \(requestId)")
                return
            }
            
            // 移除活跃请求和回调记录
            self.activeDetailRequests.removeValue(forKey: coffeeName)
            self.pendingDetailCallbacks.removeValue(forKey: requestId)
            
            switch result {
            case .success(let jsonString):
                // 打印原始响应
                print("✅ 咖啡详情请求成功: \(coffeeName), 请求ID: \(requestId)")
                
                do {
                    // 先清理 JSON 字符串，去掉可能存在的 markdown 标记
                    let cleanedJsonString = self.responseParser.cleanJSONString(jsonString)
                    
                    // 使用响应解析器提取有效的 JSON
                    let extractedJSON = try self.responseParser.extractJSONString(from: cleanedJsonString)
                    
                    guard let jsonData = extractedJSON.data(using: .utf8) else {
                        print("❌ 无法将字符串转换为数据: \(coffeeName), 请求ID: \(requestId)")
                        self.notifyAllCallbacks(callbacks, with: nil)
                        return
                    }
                    
                    // 使用响应解析器解析咖啡详情
                    if let coffeeDetail = self.responseParser.parseCoffeeDetail(jsonData: jsonData, coffeeName: coffeeName) {
                        // 通知所有等待的回调
                        self.notifyAllCallbacks(callbacks, with: coffeeDetail)
                    } else {
                        print("❌ 解析咖啡详情失败: \(coffeeName), 请求ID: \(requestId)")
                        self.notifyAllCallbacks(callbacks, with: nil)
                    }
                } catch {
                    print("❌ 提取JSON失败: \(coffeeName), 请求ID: \(requestId), 错误: \(error)")
                    self.notifyAllCallbacks(callbacks, with: nil)
                }
                
            case .failure(let error):
                print("❌ 咖啡详情请求失败: \(coffeeName), 请求ID: \(requestId), 错误: \(error)")
                
                // 处理不同类型的错误
                if let apiError = error as? ZhipuAPIError {
                    switch apiError {
                    case .networkOffline:
                        self.handleNetworkOfflineError()
                    default:
                        break
                    }
                }
                
                // 通知所有等待的回调
                self.notifyAllCallbacks(callbacks, with: nil)
            }
        }
    }
    
    // 通知所有等待的回调
    private func notifyAllCallbacks(_ callbacks: [(CoffeeDetail?) -> Void], with detail: CoffeeDetail?) {
        DispatchQueue.main.async {
            for callback in callbacks {
                callback(detail)
            }
        }
    }
    
    // 处理网络离线错误
    private func handleNetworkOfflineError() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("NetworkOfflineNotification"), object: nil)
        }
    }
} 