import Foundation
import Network

// 错误类型枚举
enum ZhipuAPIError: Error {
    case invalidURL
    case networkOffline
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

// 智谱API响应模型
struct ZhipuResponse: Decodable {
    let code: Int
    let msg: String
    let data: ZhipuData
}

struct ZhipuData: Decodable {
    let choices: [ZhipuChoice]
}

struct ZhipuChoice: Decodable {
    let content: String
}

// 智谱网络请求管理器
class ZhipuNetworkManager {
    static let shared = ZhipuNetworkManager()
    
    // 从环境变量获取API密钥，如果不存在则使用备用密钥
    private let apiKey: String = {
        if let envKey = ProcessInfo.processInfo.environment["ZHIPU_API_KEY"], !envKey.isEmpty {
            return envKey
        } else {
            print("警告: 未找到ZHIPU_API_KEY环境变量，使用备用密钥")
            return "d970f626f5834a2182f232a15c6604f9.VfLaEaHdkNWo4wvr" // 备用密钥
        }
    }()
    private let baseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    private let flashModel = "glm-4-flash" // 智谱的flash免费模型
    
    // 网络监视器
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = true
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    // 请求队列管理
    private let requestQueue = DispatchQueue(label: "RequestQueue", qos: .userInitiated)
    private var pendingRequests: [(URLRequest, (Result<String, Error>) -> Void)] = []
    private var isProcessingQueue = false
    
    private init() {
        setupNetworkMonitoring()
        checkAPIKeySource()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let wasAvailable = self.isNetworkAvailable
            self.isNetworkAvailable = path.status == .satisfied
            let isNowAvailable = path.status == .satisfied
            
            print("网络状态变更: \(isNowAvailable ? "在线" : "离线")")
            
            // 在主线程发送通知
            DispatchQueue.main.async {
                if !isNowAvailable {
                    NotificationCenter.default.post(name: Notification.Name("NetworkOfflineNotification"), object: nil)
                } else if !wasAvailable && isNowAvailable {
                    NotificationCenter.default.post(name: Notification.Name("NetworkOnlineNotification"), object: nil)
                    // 网络恢复时处理待处理的请求
                    self.processPendingRequests()
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    // 检查API密钥来源
    private func checkAPIKeySource() {
        if ProcessInfo.processInfo.environment["ZHIPU_API_KEY"] != nil {
            print("✅ 成功从环境变量加载ZHIPU_API_KEY")
        } else {
            print("⚠️ 未找到ZHIPU_API_KEY环境变量，使用备用密钥")
        }
    }
    
    // 处理待处理的请求
    private func processPendingRequests() {
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard !self.isProcessingQueue else { return }
            self.isProcessingQueue = true
            
            while !self.pendingRequests.isEmpty {
                if self.isNetworkAvailable {
                    let (request, completion) = self.pendingRequests.removeFirst()
                    self.executeRequest(request, completion: completion)
                } else {
                    break
                }
            }
            
            self.isProcessingQueue = false
        }
    }
    
    // 执行网络请求
    private func executeRequest(_ request: URLRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let maxRetries = 3
        var currentRetry = 0
        
        func performRequest() {
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    // 检查是否是超时错误
                    if (error as NSError).code == NSURLErrorTimedOut {
                        currentRetry += 1
                        if currentRetry < maxRetries {
                            print("请求超时，第\(currentRetry)次重试...")
                            // 延迟1秒后重试
                            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                                performRequest()
                            }
                            return
                        }
                    }
                    completion(.failure(ZhipuAPIError.requestFailed(error)))
                    return
                }
                
                // 处理响应数据...
                self.handleResponse(data: data, completion: completion)
            }
            task.resume()
        }
        
        performRequest()
    }
    
    // 处理响应数据
    private func handleResponse(data: Data?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let data = data else {
            completion(.failure(ZhipuAPIError.invalidResponse))
            return
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            // 首先尝试解析标准API响应
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let _ = jsonObject["code"] as? Int,
               let data = jsonObject["data"] as? [String: Any],
               let choices = data["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let content = firstChoice["content"] as? String {
                completion(.success(content))
            }
            // 尝试直接解析为JSON字符串
            else if jsonString.hasPrefix("{") || jsonString.hasPrefix("[") {
                completion(.success(jsonString))
            } else {
                completion(.failure(ZhipuAPIError.invalidResponse))
            }
        } else {
            completion(.failure(ZhipuAPIError.invalidResponse))
        }
    }
    
    // 通用的API调用方法
    func callZhipuAPI(prompt: String, parameters: [String: Any]? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        // 检查网络状态
        guard isNetworkAvailable else {
            completion(.failure(ZhipuAPIError.networkOffline))
            return
        }
        
        // 创建URL请求
        guard let url = URL(string: baseURL) else {
            completion(.failure(ZhipuAPIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        // 准备请求体
        var requestBody: [String: Any] = [
            "model": flashModel,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        if let customParams = parameters {
            requestBody.merge(customParams) { (_, new) in new }
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(ZhipuAPIError.requestFailed(error)))
            return
        }
        
        // 将请求添加到队列
        requestQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.isNetworkAvailable {
                self.executeRequest(request, completion: completion)
            } else {
                self.pendingRequests.append((request, completion))
            }
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
} 