import SwiftUI
import FirebaseAuth

// MARK: - 1. 全局设计主题
struct AppTheme {
    static let primary = Color(red: 0.0, green: 0.5, blue: 0.8) // 科技蓝
    static let secondary = Color(red: 0.2, green: 0.8, blue: 0.6) // 清新绿
    static let background = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let textDark = Color.primary
    static let textLight = Color.secondary
    
    static let cornerRadius: CGFloat = 16
    static let shadow = Color.black.opacity(0.1)
}

// MARK: - 2. 首页 (HomeView)
struct HomeView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 搜索栏
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("搜索目的地 (如: 拱北)", text: $searchText)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .shadow(color: AppTheme.shadow, radius: 5)
                        
                        // 快速筛选
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                FilterChip(title: "全部", isSelected: true)
                                FilterChip(title: "去拱北", isSelected: false)
                                FilterChip(title: "去氹仔", isSelected: false)
                                FilterChip(title: "仅女生", isSelected: false)
                            }
                            .padding(.horizontal)
                        }
                        
                        // 列表标题
                        HStack {
                            Text("最新行程")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // 行程列表 (模拟数据)
                        LazyVStack(spacing: 16) {
                            TripCardView(driverName: "陈同学", from: "E6 宿舍楼下", to: "拱北口岸", time: "今天 18:30", price: "MOP 15", seats: 2)
                            TripCardView(driverName: "王同学", from: "图书馆", to: "新八佰伴", time: "明天 09:00", price: "MOP 20", seats: 3)
                            TripCardView(driverName: "Liisa", from: "S8 荟萃坊", to: "氹仔中央公园", time: "今天 20:00", price: "MOP 12", seats: 1)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                    .padding(.top)
                }
                .navigationTitle("拼车大厅")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// MARK: - 3. 发布行程页 (PostTripView)
struct PostTripView: View {
    @State private var start = ""
    @State private var end = ""
    @State private var date = Date()
    @State private var seats = 3
    @State private var price = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("路线信息")) {
                    TextField("出发地", text: $start)
                    TextField("目的地", text: $end)
                }
                
                Section(header: Text("行程详情")) {
                    DatePicker("出发时间", selection: $date, in: Date()...)
                    Stepper("座位数: \(seats)", value: $seats, in: 1...6)
                    HStack {
                        Text("人均费用")
                        Spacer()
                        TextField("0", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("MOP").foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: { print("发布功能待实现") }) {
                        Text("确认发布")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(AppTheme.primary)
                }
            }
            .navigationTitle("发布行程")
        }
    }
}

// MARK: - 4. 个人中心页 (ProfileView)
struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var userEmail: String {
        return Auth.auth().currentUser?.email ?? "未登录"
    }
    
    var body: some View {
        NavigationView {
            List {
                HStack(spacing: 15) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(Text(userEmail.prefix(1).uppercased()).font(.title).fontWeight(.bold))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("MUST同学")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(userEmail)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
                
                Section(header: Text("我的行程")) {
                    NavigationLink(destination: Text("待出发")) { Label("待出发行程", systemImage: "clock") }
                    NavigationLink(destination: Text("历史记录")) { Label("历史记录", systemImage: "list.bullet") }
                }
                
                Section(header: Text("设置")) {
                    Button(action: performLogout) {
                        Label("退出登录", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("我的")
        }
    }
    
    func performLogout() {
        try? Auth.auth().signOut()
        withAnimation {
            isLoggedIn = false
        }
    }
}

// MARK: - 5. 辅助组件 (TripCardView & FilterChip)
struct TripCardView: View {
    let driverName: String
    let from: String
    let to: String
    let time: String
    let price: String
    let seats: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(driverName).font(.headline)
                Spacer()
                Text(price).font(.title3).fontWeight(.bold).foregroundColor(AppTheme.primary)
            }
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text(from).fontWeight(.medium)
                    Text("↓").font(.caption).foregroundColor(.gray)
                    Text(to).fontWeight(.medium)
                }
                Spacer()
                Text(time).font(.caption).foregroundColor(.gray)
            }
            HStack {
                Label("剩 \(seats) 座", systemImage: "car.fill")
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                Spacer()
                Button("加入") { }
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: AppTheme.shadow, radius: 5)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.primary : AppTheme.cardBackground)
            .foregroundColor(isSelected ? .white : .gray)
            .cornerRadius(20)
            .shadow(color: AppTheme.shadow, radius: 3)
    }
}


