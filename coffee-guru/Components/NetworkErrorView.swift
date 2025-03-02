import SwiftUI

// 重要提示：请确保将此文件添加到Xcode项目的编译目标中
// 在Xcode中，右键点击Components目录，选择"Add Files to 'coffee-guru'..."，然后选择此文件

// 网络错误提示视图
struct NetworkErrorView: View {
    @Binding var isShowing: Bool
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            // 半透明背景
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding(.horizontal, 20)
                .padding(.bottom, 5)
                .overlay(
                    HStack(spacing: 15) {
                        Image(systemName: "wifi.slash")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("网络连接错误")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            retryAction()
                        }) {
                            Text("重试")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue)
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 25)
        .transition(.move(edge: .bottom))
        .zIndex(100) // 确保显示在最上层
    }
} 