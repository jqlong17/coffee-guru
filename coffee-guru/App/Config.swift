import Foundation

/// 应用程序配置
struct AppConfig {
    /// 智谱API密钥
    static let zhipuAPIKey: String = {
        #if DEBUG
        // 开发环境：尝试从环境变量获取
        if let envKey = ProcessInfo.processInfo.environment["ZHIPU_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        #endif
        
        // 生产环境：使用硬编码密钥（应该在发布前替换为实际密钥）
        return "d970f626f5834a2182f232a15c6604f9.VfLaEaHdkNWo4wvr"
    }()
    
    /// API基础URL
    static let zhipuBaseURL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    
    /// 模型名称
    static let zhipuModel = "glm-4-flash"
    
    /// 缓存有效期（秒）
    static let cacheValidDuration: TimeInterval = 30 * 60 // 30分钟
} 