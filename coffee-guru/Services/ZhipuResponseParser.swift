import Foundation

/// 智谱 API 响应解析器
/// 负责处理所有与 JSON 解析相关的逻辑
class ZhipuResponseParser {
    
    // MARK: - 单例
    
    static let shared = ZhipuResponseParser()
    
    // MARK: - JSON 提取方法
    
    /// 从智谱 API 响应中提取有效的 JSON 字符串
    /// - Parameter input: 原始响应字符串
    /// - Returns: 提取后的 JSON 字符串
    /// - Throws: 解析错误
    func extractJSONString(from input: String) throws -> String {
        // 先尝试解析整个输入字符串为JSON对象
        if let data = input.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            // 检查是否有choices字段，且是数组
            if let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                // 从content中提取有效的JSON内容
                return content
            }
        }
        
        // 如果无法作为JSON解析或者没有按预期结构，尝试常规的JSON提取方法
        // 查找第一个 [ 和最后一个 ] 之间的内容
        if let startIndex = input.firstIndex(of: "["),
           let endIndex = input.lastIndex(of: "]") {
            let range = startIndex...endIndex
            return String(input[range])
        }
        
        // 如果无法提取数组，尝试提取对象
        if let startIndex = input.firstIndex(of: "{"),
           let endIndex = input.lastIndex(of: "}") {
            let range = startIndex...endIndex
            return String(input[range])
        }
        
        // 如果以上方法都失败，返回原始输入
        return input
    }
    
    /// 清理 JSON 字符串，去除 markdown 标记等
    /// - Parameter input: 原始 JSON 字符串
    /// - Returns: 清理后的 JSON 字符串
    func cleanJSONString(_ input: String) -> String {
        var result = input
        
        // 移除markdown代码块标记
        result = result.replacingOccurrences(of: "```json", with: "")
        result = result.replacingOccurrences(of: "```", with: "")
        
        // 移除可能的前导和尾随空白
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    // MARK: - 咖啡列表解析
    
    /// 解析咖啡列表 JSON 数据
    /// - Parameter jsonData: JSON 数据
    /// - Returns: 咖啡项数组
    /// - Throws: 解析错误
    func parseCoffeeItems(jsonData: Data) throws -> [CoffeeItem] {
        // 尝试手动解析 JSON
        if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
            var coffeeItems: [CoffeeItem] = []
            
            for (index, item) in jsonArray.enumerated() {
                // 提取字段，提供默认值
                let id = item["id"] as? Int ?? (index + 1)
                let name = item["name"] as? String ?? "未知咖啡"
                let description = item["description"] as? String ?? "无描述"
                
                // 处理 rating 可能是 Double 或 Int 的情况
                let rating: Int
                if let ratingDouble = item["rating"] as? Double {
                    rating = Int(ratingDouble.rounded())
                } else if let ratingInt = item["rating"] as? Int {
                    rating = ratingInt
                } else {
                    rating = 3
                }
                
                // 创建 CoffeeItem
                let coffeeItem = CoffeeItem(
                    id: id,
                    name: name,
                    description: description,
                    rating: rating
                )
                coffeeItems.append(coffeeItem)
            }
            
            return coffeeItems
        } else {
            // 尝试直接解码
            return try JSONDecoder().decode([CoffeeItem].self, from: jsonData)
        }
    }
    
    /// 解析精选咖啡 JSON 数据
    /// - Parameter jsonData: JSON 数据
    /// - Returns: 咖啡项
    /// - Throws: 解析错误
    func parseFeaturedCoffee(jsonData: Data) throws -> CoffeeItem {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        
        if let jsonDict = jsonObject as? [String: Any] {
            // 提取字段，提供默认值
            let id = jsonDict["id"] as? Int ?? 100
            let name = jsonDict["name"] as? String ?? "每日精选"
            let description = jsonDict["description"] as? String ?? "今日特别推荐"
            
            // 处理 rating 可能是 Double 或 Int 的情况
            let rating: Int
            if let ratingDouble = jsonDict["rating"] as? Double {
                rating = Int(ratingDouble.rounded())
            } else if let ratingInt = jsonDict["rating"] as? Int {
                rating = ratingInt
            } else {
                rating = 5
            }
            
            return CoffeeItem(
                id: id,
                name: name,
                description: description,
                rating: rating
            )
        } else if let jsonArray = jsonObject as? [[String: Any]],
                  let firstItem = jsonArray.first {
            // 如果 API 错误地返回了数组而不是对象，我们取第一个
            let id = firstItem["id"] as? Int ?? 100
            let name = firstItem["name"] as? String ?? "每日精选"
            let description = firstItem["description"] as? String ?? "今日特别推荐"
            
            // 处理 rating 可能是 Double 或 Int 的情况
            let rating: Int
            if let ratingDouble = firstItem["rating"] as? Double {
                rating = Int(ratingDouble.rounded())
            } else if let ratingInt = firstItem["rating"] as? Int {
                rating = ratingInt
            } else {
                rating = 5
            }
            
            return CoffeeItem(
                id: id,
                name: name,
                description: description,
                rating: rating
            )
        }
        
        // 如果上面的解析都失败，尝试 JSONDecoder
        return try JSONDecoder().decode(CoffeeItem.self, from: jsonData)
    }
    
    // MARK: - 咖啡详情解析
    
    /// 解析咖啡详情 JSON 数据
    /// - Parameters:
    ///   - jsonData: JSON 数据
    ///   - coffeeName: 咖啡名称（用于提供默认值）
    /// - Returns: 咖啡详情对象，如果解析失败则返回 nil
    func parseCoffeeDetail(jsonData: Data, coffeeName: String) -> CoffeeDetail? {
        do {
            // 尝试手动解析 JSON
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                let name = jsonObject["name"] as? String ?? coffeeName
                let description = jsonObject["description"] as? String ?? "暂无描述"
                let origin = jsonObject["origin"] as? String ?? "未知产地"
                let flavor = jsonObject["flavor"] as? String ?? "独特风味"
                let history = jsonObject["history"] as? String ?? "暂无历史信息"
                let price = jsonObject["price"] as? String ?? "价格不详"
                let roastLevel = jsonObject["roastLevel"] as? String ?? "中度烘焙"
                let brewMethods = jsonObject["brewMethods"] as? [String] ?? ["手冲"]
                
                // 处理 rating 可能是 Double 或 Int 的情况
                let rating: Double
                if let ratingDouble = jsonObject["rating"] as? Double {
                    rating = ratingDouble
                } else if let ratingInt = jsonObject["rating"] as? Int {
                    rating = Double(ratingInt)
                } else {
                    rating = 4.0
                }
                
                // 解析烘焙详情
                var roastingDetails: RoastingDetails? = nil
                if let roastingDict = jsonObject["roastingDetails"] as? [String: Any] {
                    roastingDetails = RoastingDetails(
                        firstCrackTime: roastingDict["firstCrackTime"] as? String ?? "8分钟",
                        secondCrackTime: roastingDict["secondCrackTime"] as? String ?? "11分钟",
                        totalRoastTime: roastingDict["totalRoastTime"] as? String ?? "15分钟",
                        roastingCurve: roastingDict["roastingCurve"] as? String ?? "标准烘焙曲线",
                        roastingNotes: roastingDict["roastingNotes"] as? String ?? "注意控制温度"
                    )
                }
                
                // 解析冲煮指南
                var brewingGuide: BrewingGuide? = nil
                if let brewingDict = jsonObject["brewingGuide"] as? [String: Any] {
                    var pourStages: [PourStage] = []
                    
                    if let stagesArray = brewingDict["pourStages"] as? [[String: Any]] {
                        for stageDict in stagesArray {
                            let stage = PourStage(
                                stageName: stageDict["stageName"] as? String ?? "注水",
                                waterAmount: stageDict["waterAmount"] as? String ?? "适量",
                                pourTime: stageDict["pourTime"] as? String ?? "30秒",
                                waitTime: stageDict["waitTime"] as? String ?? "30秒",
                                purpose: stageDict["purpose"] as? String ?? "萃取咖啡风味"
                            )
                            pourStages.append(stage)
                        }
                    }
                    
                    brewingGuide = BrewingGuide(
                        coffeeToWaterRatio: brewingDict["coffeeToWaterRatio"] as? String ?? "1:15",
                        groundSize: brewingDict["groundSize"] as? String ?? "中细研磨",
                        waterTemperature: brewingDict["waterTemperature"] as? String ?? "92°C",
                        totalBrewTime: brewingDict["totalBrewTime"] as? String ?? "3分钟",
                        pourStages: pourStages,
                        specialNotes: brewingDict["specialNotes"] as? String ?? "注意水温控制"
                    )
                }
                
                // 创建并返回 CoffeeDetail 对象
                return CoffeeDetail(
                    name: name,
                    description: description,
                    origin: origin,
                    flavor: flavor,
                    roastLevel: roastLevel,
                    brewMethods: brewMethods,
                    rating: rating,
                    history: history,
                    price: price,
                    roastingDetails: roastingDetails,
                    brewingGuide: brewingGuide
                )
            }
        } catch {
            print("解析咖啡详情 JSON 失败: \(error)")
        }
        
        return nil
    }
} 