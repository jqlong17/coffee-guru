import Foundation

/// 咖啡数据存储管理器
/// 负责处理咖啡名称的持久化存储和加载
class CoffeeDataStore {
    
    // MARK: - 单例
    
    static let shared = CoffeeDataStore()
    
    // MARK: - 存储键
    
    private enum StoreKeys {
        static let returnedCoffeeNames = "returnedCoffeeNames"
        static let returnedFeaturedCoffeeNames = "returnedFeaturedCoffeeNames"
    }
    
    // MARK: - 初始化方法
    
    private init() {}
    
    // MARK: - 咖啡名称存储方法
    
    /// 加载已返回的咖啡名称
    /// - Returns: 已返回的咖啡名称集合
    func loadReturnedCoffeeNames() -> Set<String> {
        if let savedData = UserDefaults.standard.data(forKey: StoreKeys.returnedCoffeeNames),
           let decoded = try? JSONDecoder().decode([String].self, from: savedData) {
            // 将[String]转换为Set<String>
            let coffeeNames = Set(decoded)
            print("已加载咖啡名称记录: \(coffeeNames.count)个")
            return coffeeNames
        }
        return []
    }
    
    /// 加载已返回的精选咖啡名称
    /// - Returns: 已返回的精选咖啡名称集合
    func loadReturnedFeaturedCoffeeNames() -> Set<String> {
        if let savedData = UserDefaults.standard.data(forKey: StoreKeys.returnedFeaturedCoffeeNames),
           let decoded = try? JSONDecoder().decode([String].self, from: savedData) {
            let featuredNames = Set(decoded)
            print("已加载精选咖啡名称记录: \(featuredNames)")
            return featuredNames
        }
        return []
    }
    
    /// 保存已返回的咖啡名称
    /// - Parameter coffeeNames: 要保存的咖啡名称集合
    func saveReturnedCoffeeNames(_ coffeeNames: Set<String>) {
        let coffeeNamesArray = Array(coffeeNames)
        if let encoded = try? JSONEncoder().encode(coffeeNamesArray) {
            UserDefaults.standard.set(encoded, forKey: StoreKeys.returnedCoffeeNames)
        }
    }
    
    /// 保存已返回的精选咖啡名称
    /// - Parameter featuredNames: 要保存的精选咖啡名称集合
    func saveReturnedFeaturedCoffeeNames(_ featuredNames: Set<String>) {
        let featuredNamesArray = Array(featuredNames)
        if let encoded = try? JSONEncoder().encode(featuredNamesArray) {
            UserDefaults.standard.set(encoded, forKey: StoreKeys.returnedFeaturedCoffeeNames)
        }
    }
    
    /// 清除所有已保存的咖啡名称
    func clearAllCoffeeNames() {
        UserDefaults.standard.removeObject(forKey: StoreKeys.returnedCoffeeNames)
        UserDefaults.standard.removeObject(forKey: StoreKeys.returnedFeaturedCoffeeNames)
        print("已清除所有咖啡名称记录")
    }
} 