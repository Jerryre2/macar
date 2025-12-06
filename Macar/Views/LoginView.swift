

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 这里的 path 用于管理页面跳转
    @State private var path = NavigationPath()
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // 背景
                LinearGradient(colors: [Color.blue.opacity(0.1), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo 区域
                    VStack(spacing: 10) {
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding()
                            .background(Circle().fill(Color.white).shadow(radius: 10))
                        
                        Text("澳门科技大学拼车")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 50)
                    
                    // 输入框区域
                    VStack(spacing: 20) {
                        TextField("学校邮箱", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("密码", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // 登录按钮
                    Button(action: performLogin) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("登 录").fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    Spacer()
                    
                    // 注册跳转链接
                    // 注意：这里绝对不能写 RegistrationView()，必须用 NavigationLink
                    HStack {
                        Text("还没有账号?")
                            .foregroundColor(.gray)
                        
                        // 点击这里告诉系统跳转到 "Register" 标签
                        NavigationLink(value: "Register") {
                            Text("立即注册")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            // 这里定义跳转目的地：当点击 "Register" 时，才显示 RegistrationView
            .navigationDestination(for: String.self) { value in
                if value == "Register" {
                    RegistrationView()
                }
            }
            .toolbar(.hidden, for: .navigationBar) // 隐藏登录页的导航栏
            .alert(isPresented: $showError) {
                Alert(title: Text("登录失败"), message: Text(errorMessage), dismissButton: .default(Text("好的")))
            }
        }
    }
    
    func performLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "请输入邮箱和密码"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                print("登录成功")
                withAnimation {
                    isLoggedIn = true
                }
            }
        }
    }
}
