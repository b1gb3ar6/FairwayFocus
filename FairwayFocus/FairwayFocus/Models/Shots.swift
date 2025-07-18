//
//  Shots.swift
//  GolfTest
//
//  Created by Ben Hester on 17/07/2025.
//

import Foundation

struct Shot: Identifiable {
    let id = UUID()
    let club: String
    let distance: Double
    let deviation: Double
    
    init(club: String, distance: Double, deviation: Double) {
        self.club = club
        self.distance = distance
        self.deviation = deviation
    }
    
    init?(from dictionary: [String: Any]) {
        guard let club = dictionary["club"] as? String,
              let distance = dictionary["distance"] as? Double,
              let deviation = dictionary["deviation"] as? Double else {
            return nil
        }
        self.club = club
        self.distance = distance
        self.deviation = deviation
    }
    
    func toDictionary() -> [String: Any] {
        [
            "club": club,
            "distance": distance,
            "deviation": deviation
        ]
    }
}
