import Foundation
import SwiftUI

// 咖啡数据模型
struct CoffeeItem: Identifiable, Hashable, Codable {
    var id: Int
    let name: String
    let description: String
    let rating: Int
    
    // 自定义解码器，以处理浮点数或整数的rating
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? Int.random(in: 1...1000)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        
        // 处理rating可能是整数或浮点数的情况
        if let intRating = try? container.decode(Int.self, forKey: .rating) {
            rating = intRating
        } else if let doubleRating = try? container.decode(Double.self, forKey: .rating) {
            rating = Int(doubleRating.rounded())
        } else {
            rating = 4 // 默认值
        }
    }
    
    // 普通初始化方法
    init(id: Int, name: String, description: String, rating: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.rating = rating
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, rating
    }
    
    static func == (lhs: CoffeeItem, rhs: CoffeeItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// 咖啡详情数据模型
struct CoffeeDetail: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let description: String
    let origin: String
    let flavor: String
    let roastLevel: String
    let brewMethods: [String]
    let rating: Double
    let history: String
    let price: String
    
    // 新增的详细字段
    let roastingDetails: RoastingDetails?  // 烘焙详情
    let brewingGuide: BrewingGuide?        // 冲煮指南
    
    // 自定义解码器，处理更灵活的JSON格式
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        origin = try container.decode(String.self, forKey: .origin)
        flavor = try container.decode(String.self, forKey: .flavor)
        roastLevel = try container.decode(String.self, forKey: .roastLevel)
        
        // 处理brewMethods可能是字符串或数组的情况
        if let methodsArray = try? container.decode([String].self, forKey: .brewMethods) {
            brewMethods = methodsArray
        } else if let methodString = try? container.decode(String.self, forKey: .brewMethods) {
            // 如果是字符串，按逗号分割
            brewMethods = methodString.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        } else {
            brewMethods = ["手冲"] // 默认值
        }
        
        // 处理rating可能是整数或浮点数的情况
        if let doubleRating = try? container.decode(Double.self, forKey: .rating) {
            rating = doubleRating
        } else if let intRating = try? container.decode(Int.self, forKey: .rating) {
            rating = Double(intRating)
        } else {
            rating = 4.5 // 默认值
        }
        
        history = try container.decode(String.self, forKey: .history)
        price = try container.decode(String.self, forKey: .price)
        
        // 尝试解码新增字段，不存在则设为nil
        roastingDetails = try? container.decode(RoastingDetails.self, forKey: .roastingDetails)
        brewingGuide = try? container.decode(BrewingGuide.self, forKey: .brewingGuide)
    }
    
    // 普通初始化方法
    init(name: String, description: String, origin: String, flavor: String, roastLevel: String, 
         brewMethods: [String], rating: Double, history: String, price: String,
         roastingDetails: RoastingDetails? = nil, brewingGuide: BrewingGuide? = nil) {
        self.name = name
        self.description = description
        self.origin = origin
        self.flavor = flavor
        self.roastLevel = roastLevel
        self.brewMethods = brewMethods
        self.rating = rating
        self.history = history
        self.price = price
        self.roastingDetails = roastingDetails
        self.brewingGuide = brewingGuide
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, origin, flavor, roastLevel, brewMethods, rating, history, price
        case roastingDetails, brewingGuide
    }
}

// 咖啡烘焙详情模型
struct RoastingDetails: Codable {
    let firstCrackTime: String     // 一爆时间
    let secondCrackTime: String    // 二爆时间（如果适用）
    let totalRoastTime: String     // 总烘焙时间
    let roastingCurve: String      // 烘焙曲线简述
    let roastingNotes: String      // 烘焙注意事项和建议
    
    // 简化的初始化方法，减少所需参数
    init(firstCrackTime: String, secondCrackTime: String, totalRoastTime: String, 
         roastingCurve: String = "", roastingNotes: String = "") {
        self.firstCrackTime = firstCrackTime
        self.secondCrackTime = secondCrackTime
        self.totalRoastTime = totalRoastTime
        self.roastingCurve = roastingCurve
        self.roastingNotes = roastingNotes
    }
}

// 咖啡冲煮指南模型
struct BrewingGuide: Codable {
    let coffeeToWaterRatio: String       // 粉水比
    let groundSize: String               // 研磨度
    let waterTemperature: String         // 水温
    let totalBrewTime: String            // 总冲煮时间
    let pourStages: [PourStage]          // 分段注水详情
    let specialNotes: String             // 特别注意事项
    
    // 简化的初始化方法
    init(coffeeToWaterRatio: String, groundSize: String, waterTemperature: String,
         totalBrewTime: String, pourStages: [PourStage] = [], specialNotes: String = "") {
        self.coffeeToWaterRatio = coffeeToWaterRatio
        self.groundSize = groundSize
        self.waterTemperature = waterTemperature
        self.totalBrewTime = totalBrewTime
        self.pourStages = pourStages
        self.specialNotes = specialNotes
    }
}

// 注水阶段模型
struct PourStage: Codable {
    let stageName: String      // 阶段名称（如"预浸泡"，"第一次注水"等）
    let waterAmount: String    // 水量
    let pourTime: String       // 注水时间
    let waitTime: String       // 等待时间
    let purpose: String        // 这个阶段的目的
    
    init(stageName: String, waterAmount: String, pourTime: String, waitTime: String, purpose: String = "") {
        self.stageName = stageName
        self.waterAmount = waterAmount
        self.pourTime = pourTime
        self.waitTime = waitTime
        self.purpose = purpose
    }
}

// 咖啡主题颜色
extension Color {
    static let coffeeBackground = Color(hex: "FAF3E0")
    static let coffeePrimary = Color(hex: "6F4E37")
    static let coffeeSecondary = Color(hex: "B85C38")
    static let coffeeAccent = Color(hex: "A67C52")
    static let coffeeLightBrown = Color(hex: "D7B29D")
    static let coffeeCream = Color(hex: "FFF8E7")
    static let coffeeTextLight = Color(hex: "FFFFFF")
}

// 颜色十六进制转换扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 简化的动画
extension Animation {
    static let coffeeRotation = Animation.linear(duration: 2).repeatForever(autoreverses: false)
    static let coffeeIconPulse = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    static let gearRotation = Animation.linear(duration: 10).repeatForever(autoreverses: false)
} 