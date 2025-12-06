// 文件名: MacarApp.swift (或者你的项目名App.swift)
import SwiftUI
import FirebaseCore

@main
struct MacarApp: App {
    // 初始化 Firebase
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // 这里只能有一个根视图
            MainContentView()
        }
    }
}
