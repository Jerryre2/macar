import MapKit

class RouteManager {
    
    // 检查乘客加入是否会导致绕路过多
    func checkDetour(currentRoute: [LocationPoint], newPickup: LocationPoint, newDropoff: LocationPoint) async -> Bool {
        
        // 1. 计算原始路线时间
        let originalTime = await calculateRouteTime(points: currentRoute)
        
        // 2. 构建新路线 (简单插入：起点 -> 新起点 -> 新终点 -> 原终点)
        // 实际算法可能需要尝试不同的插入位置
        var newRoutePoints = currentRoute
        newRoutePoints.insert(newPickup, at: 1)
        newRoutePoints.insert(newDropoff, at: 2)
        
        // 3. 计算新时间
        let newTime = await calculateRouteTime(points: newRoutePoints)
        
        // 4. 判定：如果增加时间超过 15 分钟或 30%，则拒绝
        let extraTime = newTime - originalTime
        if extraTime > 15 * 60 { return false }
        
        return true
    }
    
    private func calculateRouteTime(points: [LocationPoint]) async -> TimeInterval {
        guard points.count >= 2 else { return 0 }
        
        var totalTime: TimeInterval = 0
        
        for i in 0..<(points.count - 1) {
            let req = MKDirections.Request()
            req.source = MKMapItem(placemark: MKPlacemark(coordinate: points[i].coordinate))
            req.destination = MKMapItem(placemark: MKPlacemark(coordinate: points[i+1].coordinate))
            req.transportType = .automobile
            
            if let response = try? await MKDirections(request: req).calculate() {
                totalTime += response.routes.first?.expectedTravelTime ?? 0
            }
        }
        return totalTime
    }
}
//

