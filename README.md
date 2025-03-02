# 咖啡大师 (Coffee Guru)

一个精美的iOS应用，用于探索和了解各种精品咖啡的信息，包括咖啡特性、烘焙方法和冲泡指南。

## 项目目标

- 为咖啡爱好者提供一个直观、美观的应用程序，帮助他们探索和了解各种咖啡
- 展示现代iOS应用程序开发的最佳实践
- 实现高性能、响应式的用户界面
- 采用模块化架构，便于维护和扩展

## 核心功能

- **咖啡浏览**：浏览各种咖啡品种，包括详细信息和特性
- **精选推荐**：每日精选咖啡推荐
- **冲泡指南**：不同咖啡的冲泡方法和技巧
- **收藏功能**：保存喜爱的咖啡品种
- **搜索功能**：快速查找特定咖啡
- **离线支持**：主要功能在离线状态下可用

## 技术栈

- **SwiftUI**：用于构建现代、响应式的用户界面
- **Combine**：用于响应式编程和数据流管理
- **MVVM架构**：清晰分离视图、视图模型和模型层
- **设计系统**：统一的设计语言，确保UI一致性
- **智谱AI API**：使用GLM-4-Flash模型获取咖啡相关数据

## 代码结构

```
coffee-guru/
├── App/                # 应用程序入口和配置
├── Assets.xcassets/    # 图像、颜色和其他资源
├── Components/         # 可重用UI组件
├── Extensions/         # 扩展功能
│   └── DesignSystem.swift # 设计系统定义
├── Models/             # 数据模型和视图模型
│   ├── Models.swift    # 数据模型定义
│   └── HomeViewModel.swift # 首页视图模型
├── Services/           # 网络和数据服务
│   ├── ZhipuAPIService.swift      # 智谱API服务
│   ├── ZhipuNetworkManager.swift  # 网络管理器
│   ├── ZhipuResponseParser.swift  # 响应解析器
│   ├── CoffeeDataStore.swift      # 咖啡数据存储
│   ├── CoffeePreloadService.swift # 咖啡预加载服务
│   └── Prompts/        # API提示模板
├── Views/              # 应用程序视图
│   ├── Home/           # 主页相关视图
│   ├── CoffeeDetail/   # 咖啡详情视图
│   ├── Cards/          # 卡片组件视图
│   └── Other/          # 其他辅助视图
└── Preview Content/    # SwiftUI预览资源
```

## 开发环境

- Xcode 14.0+
- Swift 5.7+
- iOS 16.0+

## 如何运行

1. 克隆仓库
2. 使用Xcode打开项目
3. 选择目标设备或模拟器
4. 点击运行按钮

## 文档

- [架构设计](./ARCHITECTURE.md)：详细的架构设计文档
- [UI设计系统](./UI_DESIGN.md)：UI组件和设计系统说明

## 最近更新

- 添加了CoffeePreloadService服务，优化咖啡详情预加载逻辑
- 实现了CoffeeDataStore类，分离数据存储逻辑
- 优化了卡片可见性检测和预加载机制
- 重构了HomeViewModel，减少职责，提高可维护性

## 贡献

欢迎提交问题和拉取请求！ 