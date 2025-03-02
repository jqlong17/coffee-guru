//
//  coffee_guruApp.swift
//  coffee-guru
//
//  Created by 龙嘉奇 on 2025/3/2.
//

import SwiftUI

@main
struct coffee_guruApp: App {
    init() {
        // 设置全局UI样式
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color.white)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // 设置导航栏样式
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = UIColor(Color(hex: "FAF3E0"))
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "6F4E37"))]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
