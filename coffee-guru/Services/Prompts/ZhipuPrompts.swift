import Foundation

/// 智谱 API 的提示模板
struct ZhipuPrompts {
    
    // MARK: - 咖啡列表提示
    
    /// 获取咖啡列表的提示模板
    /// - Parameters:
    ///   - offset: 偏移量，用于分页
    ///   - existingNames: 已经返回过的咖啡名称
    /// - Returns: 格式化后的提示字符串
    static func coffeeListPrompt(offset: Int, existingNames: String) -> String {
        return """
        请以JSON格式返回5个精品咖啡项，每个包含以下字段：
        id: 唯一标识符（数字，从\(offset + 1)开始递增）
        name: 咖啡名称（请确保与之前的不同，提供新的咖啡名称）
        description: 简短描述（50字以内）
        rating: 评分（1-5之间的数字）
        
        已经返回过的咖啡名称：\(existingNames)
        请确保不要返回上述已有的咖啡名称，提供全新的咖啡项。
        
        直接返回JSON数组，不要有其他文字。格式如下：
        [
          {
            "id": \(offset + 1),
            "name": "埃塞俄比亚耶加雪啡",
            "description": "来自埃塞俄比亚的优质咖啡豆，具有柑橘和花香气息",
            "rating": 4.5
          },
          ...
        ]
        
        注意：这是第\(offset/5 + 1)页数据，请确保返回与之前页不同的咖啡项。
        """
    }
    
    // MARK: - 精选咖啡提示
    
    /// 获取精选咖啡的提示模板
    /// - Parameter namesString: 已经返回过的精选咖啡名称
    /// - Returns: 格式化后的提示字符串
    static func featuredCoffeePrompt(namesString: String) -> String {
        return """
        请以JSON格式返回一个独特的精选咖啡项，必须提供一个与"埃塞俄比亚耶加雪啡"不同的咖啡名称。
        要求包含以下字段：
        id: 唯一标识符（数字）
        name: 一个特别的、独特的咖啡名称（一般为产地和产区命名）
        description: 生动详细的咖啡描述（50字以内）
        rating: 评分（1-5之间的数字，可以带小数）
        
        已经返回过的精选咖啡名称：\(namesString)
        请确保不要返回上述已有的咖啡名称，提供全新的咖啡项。
        
        // 要求：
        // 1. 每次返回不同的咖啡种类
        // 2. 描述要有吸引力且独特
        // 3. 请突出咖啡的特色和魅力
        
        // 直接返回JSON对象，不要有其他文字。格式如下：
        // {
        //   "id": 2,
        //   "name": "肯尼亚AA精选",
        //   "description": "来自肯尼亚高海拔山区的顶级咖啡豆，具有明亮的酸度和浆果风味",
        //   "rating": 4.7
        // }
        """
    }
    
    // MARK: - 咖啡详情提示
    
    /// 获取咖啡详情的提示模板
    /// - Parameter coffeeName: 咖啡名称
    /// - Returns: 格式化后的提示字符串
    static func coffeeDetailPrompt(coffeeName: String) -> String {
        return """
        请以JSON格式返回关于"\(coffeeName)"的详细信息，包含以下字段：
        
        // 基本信息
        name: 咖啡名称（与请求的名称相同）
        description: 详细描述（200字左右）
        origin: 产地信息（50字左右）
        flavor: 风味特点（50字左右）
        history: 历史背景（100字左右）
        price: 咖啡生豆价格范围（人民币元/kg）
        
        // 加工处理信息
        roastLevel: 烘焙程度（浅焙/中焙/深焙）
        brewMethods: 推荐冲泡方法（数组）
        rating: 评分（1-5之间的数字）
        
        同时，请务必提供以下详细的烘焙和冲煮信息（这些信息对显示完整详情至关重要）：
        
        roastingDetails: {
          firstCrackTime: 针对"\(coffeeName)"的一爆时间点（例如"8分钟"），解释为何此咖啡在这个时间点达到一爆
          secondCrackTime: 针对"\(coffeeName)"的二爆时间点（例如"11分30秒"或"不适用"），解释是否适合此咖啡达到二爆
          totalRoastTime: 针对"\(coffeeName)"的建议总烘焙时间（例如"15分钟"），解释为何这个时间适合此咖啡
          roastingCurve: 针对"\(coffeeName)"的烘焙曲线详细描述，要根据这种豆子的产地、密度、含水量和风味特性来设计曲线（例如"前5分钟缓慢升温，6-8分钟快速升温至一爆"）
          roastingNotes: 关于烘焙"\(coffeeName)"的专业指导（200字左右），请以连贯的段落形式详细说明这种咖啡的烘焙特点和注意事项。
        }
        
        brewingGuide: {
          coffeeToWaterRatio: 最适合"\(coffeeName)"的咖啡粉与水的比例（例如"1:15"）
          groundSize: 最适合"\(coffeeName)"的研磨度（例如"中细研磨"）
          waterTemperature: 最适合"\(coffeeName)"的水温（例如"92°C"）
          totalBrewTime: 最适合"\(coffeeName)"的总冲煮时间（例如"3分钟"）
          specialNotes: 冲煮"\(coffeeName)"的特别注意事项（50字左右）
          pourStages: [
            // 请务必提供至少3个完整的冲泡阶段，专业的手冲咖啡从不只有一个阶段
            {
              stageName: 阶段名称（如"预浸泡"）
              waterAmount: 使用的水量（例如"40ml"）
              pourTime: 注水时间（例如"30秒"）
              waitTime: 等待时间（例如"45秒"）
              purpose: 这个阶段对"\(coffeeName)"的特定目的（例如"释放二氧化碳，预湿咖啡粉"）
            },
            {
              stageName: 第二阶段名称（如"第一次主注水"）
              waterAmount: 第二阶段水量（例如"150ml"）
              pourTime: 第二阶段注水时间
              waitTime: 第二阶段等待时间
              purpose: 第二阶段的特定目的
            },
            {
              stageName: 第三阶段名称（如"最终注水"）
              waterAmount: 第三阶段水量（例如"剩余水量"）
              pourTime: 第三阶段注水时间
              waitTime: 第三阶段等待时间
              purpose: 第三阶段的特定目的
            }
            // 可以有多个注水阶段
          ]
        }
        
        请确保JSON响应中一定包含roastingDetails和brewingGuide这两个完整的对象，且内容必须专门针对"\(coffeeName)"的特性定制，不要提供通用的烘焙和冲煮指南。
        
        直接返回完整的JSON对象，包含所有上述字段，不要有任何markdown标记或代码块格式（不要包含```json或```这样的标记）。
        确保JSON格式严格正确，所有字符串都有引号，响应可以直接被JSON解析器解析。
        所有字段务必包含，这对应用展示非常重要。请花点时间仔细构造回答，确保每个字段都有合理有趣的内容。
        """
    }
} 