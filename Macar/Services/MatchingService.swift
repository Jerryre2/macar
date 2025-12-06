import Foundation
import CoreLocation

struct MatchRequest {
    let from: LocationPoint
    let to: LocationPoint
    let time: Date
}

class MatchingEngine {
    
    // 计算两个行程的匹配度 (0.0 - 1.0)
    func calculateScore(request: MatchRequest, candidate: Trip) -> Double {
        // 1. 时间权重 (30%)
        let timeDiff = abs(request.time.timeIntervalSince(candidate.startTime))
        // 如果时间差超过 20 分钟，直接不匹配
        if timeDiff > 20 * 60 { return 0.0 }
        let timeScore = max(0, 1.0 - (timeDiff / (20 * 60)))
        
        // 2. 距离权重 (起点距离 + 终点距离) (50%)
        let startDist = distance(p1: request.from, p2: candidate.startLocation)
        let endDist = distance(p1: request.to, p2: candidate.endLocation)
        
        // 假设起点终点各允许 1km 偏差
        if startDist > 1000 || endDist > 1000 { return 0.0 }
        
        let distScore = (max(0, 1.0 - startDist/1000) + max(0, 1.0 - endDist/1000)) / 2.0
        
        // 3. 剩余座位 (20%)
        let seatScore = candidate.availableSeats > 0 ? 1.0 : 0.0
        
        // 总分
        return (timeScore * 0.3) + (distScore * 0.5) + (seatScore * 0.2)
    }
    
    // Haversine 距离计算 (简化版)
    private func distance(p1: LocationPoint, p2: LocationPoint) -> Double {
        let loc1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let loc2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        return loc1.distance(from: loc2) // 返回米
    }
}
