import SwiftUI
import Combine

struct CreateTripView: View {
    @StateObject var viewModel = CreateTripViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("路线信息")) {
                    TextField("出发地 (例如: 土木工程实验楼对面)", text: $viewModel.startLocation)
                    TextField("目的地 (例如: 横琴口岸G1)", text: $viewModel.endLocation)
                }
                
                Section(header: Text("时间与座位")) {
                    DatePicker("出发时间", selection: $viewModel.startTime, in: Date()...)
                    Stepper("提供座位: \(viewModel.seats)", value: $viewModel.seats, in: 1...6)
                }
                
                Section(header: Text("费用 (MOP)")) {
                    TextField("人均费用", value: $viewModel.price, format: .currency(code: "MOP"))
                        .keyboardType(.decimalPad)
                }
                
                Button(action: {
                    Task { await viewModel.publishTrip() }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("发布行程")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("发起拼车")
        }
    }
}

class CreateTripViewModel: ObservableObject {
    @Published var startLocation = ""
    @Published var endLocation = ""
    @Published var startTime = Date()
    @Published var seats = 3
    @Published var price: Double = 10.0
    @Published var isLoading = false
    
    func publishTrip() async {
        isLoading = true
        // 1. 验证输入
        // 2. 调用 NetworkManager 发送 POST 请求
        // 3. 处理结果
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 模拟网络
        isLoading = false
    }
}

