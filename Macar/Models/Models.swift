import Foundation
import CoreLocation

// 用户模型
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let studentId: String // 学号
    let schoolEmail: String // 必须是 .edu.mo 结尾
    let gender: Gender
    let isVerified: Bool
}

enum Gender: String, Codable {
    case male, female, unknown
}

// 行程模型
struct Trip: Codable, Identifiable {
    let id: String
    let driverId: String
    let startLocation: LocationPoint
    let endLocation: LocationPoint
    let startTime: Date
    let totalSeats: Int
    var availableSeats: Int
    let pricePerPerson: Decimal
    let status: TripStatus
    let routePoints: [LocationPoint] // 途径点
}

struct LocationPoint: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum TripStatus: String, Codable {
    case open, full, inProgress, completed, cancelled
}
//  Untitled.swift
//  Macar
//
//  Created by 葛泰泽 on 04/12/2025.
//

