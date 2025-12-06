import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    // MARK: - 状态变量
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var phone: String = ""
    @State private var selectedCountryCode: String = "+853"
    
    // 验证状态
    @State private var isEmailValid: Bool = false
    @State private var isPasswordValid: Bool = false
    @State private var showPasswordMismatch: Bool = false
    
    // 加载与错误处理
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    
    // 修改点：使用新的 dismiss 环境变数
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // 标题区
                    VStack(alignment: .leading, spacing: 10) {
                        Text("创建账号")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.8))
                        Text("加入 MUST 拼车社区")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    // 表单区域
                    VStack(spacing: 20) {
                        // 1. 邮箱输入
                        RegCustomTextField(icon: "envelope", placeholder: "学校邮箱 (@must.edu.mo)", text: $email)
                            .textInputAutocapitalization(.never)
                            .onChange(of: email) { newValue in
                                email = newValue.lowercased()
                                validateEmail()
                            }
                        
                        // 2. 手机号
                        if isEmailValid {
                            HStack {
                                Picker(selection: $selectedCountryCode, label: Text("区号")) {
                                    Text("🇨🇳 +86").tag("+86")
                                    Text("🇲🇴 +853").tag("+853")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 100)
                                .padding(.vertical, 12)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(10)
                                
                                RegCustomTextField(icon: "phone", placeholder: "手机号码", text: $phone)
                                    .keyboardType(.phonePad)
                            }
                            .transition(.opacity)
                        }
                        
                        // 3. 密码输入
                        if !phone.isEmpty {
                            VStack(spacing: 15) {
                                RegCustomTextField(icon: "lock", placeholder: "设置密码 (至少6位)", text: $password, isSecure: true)
                                    .onChange(of: password) { _ in validatePassword() }
                                
                                RegCustomTextField(icon: "lock.fill", placeholder: "确认密码", text: $confirmPassword, isSecure: true)
                                    .onChange(of: confirmPassword) { _ in validatePassword() }
                                
                                if showPasswordMismatch {
                                    Text("两次输入的密码不一致")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.spring(), value: isEmailValid)
                    .animation(.spring(), value: phone.isEmpty)
                    
                    // 注册按钮
                    Button(action: performRegistration) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("立即注册")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(isFormValid ? Color(red: 0.0, green: 0.5, blue: 0.8) : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!isFormValid || isLoading)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
        }
        // 确保导航栏标题显示模式正确
        .navigationBarTitleDisplayMode(.inline)
        // 显式显示导航栏，防止被 LoginView 的设置影响
        .toolbar(.visible, for: .navigationBar)
        .alert(isPresented: $showError) {
            Alert(title: Text("注册失败"), message: Text(errorMessage), dismissButton: .default(Text("好的")))
        }
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("注册成功"),
                message: Text("验证邮件已发送至 \(email)，请查收后登录。"),
                dismissButton: .default(Text("去登录")) {
                    // 返回登录页
                    dismiss()
                }
            )
        }
    }
    
    // MARK: - 验证逻辑
    var isFormValid: Bool {
        return isEmailValid && isPasswordValid && !phone.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    func validateEmail() {
        isEmailValid = email.contains("@")
    }
    
    func validatePassword() {
        showPasswordMismatch = !confirmPassword.isEmpty && password != confirmPassword
        isPasswordValid = password.count >= 6 && password == confirmPassword
    }
    
    // MARK: - 注册逻辑
    func performRegistration() {
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            if let uid = result?.user.uid {
                let userData: [String: Any] = [
                    "uid": uid,
                    "email": email,
                    "phone": "\(selectedCountryCode) \(phone)",
                    "createdAt": FieldValue.serverTimestamp(),
                    "isVerified": false
                ]
                
                Firestore.firestore().collection("users").document(uid).setData(userData) { err in
                    isLoading = false
                    if let err = err {
                        errorMessage = "账号创建成功但保存数据失败: \(err.localizedDescription)"
                        showError = true
                    } else {
                        result?.user.sendEmailVerification()
                        showSuccess = true
                    }
                }
            }
        }
    }
}

// MARK: - 专用组件定义
struct RegCustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.8))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
