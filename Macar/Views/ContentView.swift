// 文件名: MainContentView.swif// 文件名: MainContentView.swift
import SwiftUI
import FirebaseAuth

struct MainContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        // 这里只是一个简单的 if-else 切换
        if isLoggedIn {
            // 登录成功后显示的页面
            TabView {
                Text("首页").tabItem { Image(systemName: "house"); Text("首页") } // 替换为你真正的 HomeView()
                Text("发布").tabItem { Image(systemName: "plus"); Text("发布") }
                Text("我的").tabItem { Image(systemName: "person"); Text("我的") }
            }
        } else {
            // 未登录时只显示 LoginView
            // 注意：不要在这里加 NavigationStack，LoginView 内部已经有了
            LoginView()
        }
    }
}
