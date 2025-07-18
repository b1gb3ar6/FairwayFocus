//
//  TestSession.swift
//  GolfTest
//
//  Created by Ben Hester on 17/07/2025.
//

import Foundation

struct TestSession: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let insights: String
    let shots: [Shot]
    
    init(date: Date, score: Double, insights: String, shots: [Shot]) {
        self.date = date
        self.score = score
        self.insights = insights
        self.shots = shots
    }
    
    init?(from dictionary: [String: Any]) {
        guard let date = dictionary["date"] as? Date,
              let score = dictionary["score"] as? Double,
              let insights = dictionary["insights"] as? String,
              let shotsData = dictionary["shots"] as? [[String: Any]] else {
            return nil
        }
        self.date = date
        self.score = score
        self.insights = insights
        self.shots = shotsData.compactMap { Shot(from: $0) }
    }
    
    func toDictionary() -> [String: Any] {
        [
            "date": date,
            "score": score,
            "insights": insights,
            "shots": shots.map { $0.toDictionary() }
        ]
    }
}
