//
//  ClubCategory.swift
//  GolfTest
//
//  Created by Ben Hester on 17/07/2025.
//

import Foundation  // No UI here, so Foundation is enough

struct ClubCategory: Identifiable {
    let id = UUID()
    let name: String
    let clubs: [String]
}
