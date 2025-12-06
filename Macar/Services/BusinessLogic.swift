import Foundation
struct TripValidator {
    
    static func canJoinTrip(userRequest: MatchRequest, trip: Trip, user: User) -> (Bool, String) {
        // 1. 状态检查
        if trip.status != .open {
            return (false, "行程已关闭或已结束")
        }
        
        // 2. 座位检查
        if trip.availableSeats <= 0 {
            return (false, "座位已满")
        }
        
        // 3. 性别偏好 (假设 Trip 有 genderPreference 字段)
        // if let pref = trip.genderPreference, pref != user.gender {
        //    return (false, "车主限制性别")
        // }
        
        // 4. 时间检查 (不能加入已经开始的行程)
        if Date() > trip.startTime {
            return (false, "行程已开始")
        }
        
        return (true, "可以加入")
    }
}

