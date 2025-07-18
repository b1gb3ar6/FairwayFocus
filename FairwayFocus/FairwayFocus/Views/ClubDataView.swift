import SwiftUI
import Charts

struct ClubDataView: View {
    @State private var sessions: [TestSession] = []  // Loaded from UserDefaults
    
    // All shots across sessions
    private var allShots: [Shot] {
        sessions.flatMap { $0.shots }
    }
    
    // Grouped data: Avg, min, max distance, avg deviation (signed for L/R), and score per club
    private var clubStats: [(club: String, abbr: String, avgDistance: Double, minDistance: Double, maxDistance: Double, avgDeviation: Double, score: Double)] {
        let grouped = Dictionary(grouping: allShots, by: { $0.club })
        
        var stats: [(club: String, abbr: String, avgDistance: Double, minDistance: Double, maxDistance: Double, avgDeviation: Double, score: Double)] = []
        for (club, shots) in grouped {
            let distances = shots.map { $0.distance }
            let deviations = shots.map { $0.deviation }  // Signed deviations
            
            let sumDistance = distances.reduce(0.0, +)
            let count = Double(shots.count)
            let avgDist = sumDistance / count
            let minDist = distances.min() ?? 0.0
            let maxDist = distances.max() ?? 0.0
            let avgDev = deviations.reduce(0.0, +) / count  // Signed average deviation
            
            // Simple score: 100 - (abs(avgDev) * 2) - ((maxDist - minDist) / 2), clamped 0-100
            let dispersionPenalty = abs(avgDev) * 2
            let distanceVariancePenalty = (maxDist - minDist) / 2
            let rawScore = 100 - dispersionPenalty - distanceVariancePenalty
            let score = max(0, min(100, rawScore))
            
            let abbr = clubAbbr(for: club)
            stats.append((club: club, abbr: abbr, avgDistance: avgDist, minDistance: minDist, maxDistance: maxDist, avgDeviation: avgDev, score: score))
        }
        
        return stats.sorted { $0.avgDistance > $1.avgDistance }  // Sort by descending avg distance
    }
    
    // Color for score (traffic light with shades)
    private func scoreColor(for score: Double) -> Color {
        if score > 90 { return Color.green.opacity(1.0) }  // Dark green
        if score > 80 { return Color.green.opacity(0.8) }  // Medium green
        if score > 70 { return Color.green.opacity(0.6) }  // Light green
        if score > 60 { return Color.yellow.opacity(1.0) }  // Dark yellow
        if score > 50 { return Color.yellow.opacity(0.8) }  // Medium yellow
        if score > 40 { return Color.yellow.opacity(0.6) }  // Light yellow
        if score > 30 { return Color.red.opacity(0.6) }  // Light red
        if score > 20 { return Color.red.opacity(0.8) }  // Medium red
        return Color.red.opacity(1.0)  // Dark red
    }
    
    // Extracted Avg Distance Chart View (reduced padding and frame for better fit)
    private var avgDistanceChart: some View {
        Chart {
            ForEach(clubStats, id: \.club) { data in
                BarMark(
                    x: .value("Avg Distance", data.avgDistance),
                    y: .value("Club", data.club)
                )
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.gray, .primaryGreen]), startPoint: .leading, endPoint: .trailing))  // Reversed gradient direction
                .annotation(position: .trailing, alignment: .leading) {
                    Text("\(data.avgDistance, specifier: "%.0f")")
                        .font(.caption2)  // Smaller font
                        .foregroundColor(.primaryText)
                        .padding(.leading, 2)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let club = value.as(String.self) {
                    let abbr = clubAbbr(for: club)
                    AxisValueLabel {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)  // Smaller circle
                            Text(abbr)
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .chartXAxisLabel("", alignment: .trailing)
        .frame(height: 250)  // Reduced height
        .padding(.horizontal, 10)  // Reduced horizontal padding
    }
    
    // Info graphic style table for club stats (reduced widths for better fit)
    private var clubStatsTable: some View {
        VStack(spacing: 8) {  // Reduced spacing
            // Header row
            HStack {
                Text("Club")
                    .frame(minWidth: 40, alignment: .leading)
                Text("Avg")
                    .frame(minWidth: 40, alignment: .center)
                Text("Min")
                    .frame(minWidth: 40, alignment: .center)
                Text("Max")
                    .frame(minWidth: 40, alignment: .center)
                Text("Dev")
                    .frame(minWidth: 60, alignment: .center)  // Slightly wider for L/R
                Text("Score")
                    .frame(minWidth: 50, alignment: .center)
            }
            .font(.caption2)  // Smaller font
            .bold()
            .foregroundColor(.primaryText)
            .padding(.horizontal, 10)
            
            ForEach(clubStats, id: \.club) { data in
                HStack {
                    Text(data.abbr)
                        .bold()  // Bold abbreviations
                        .font(.subheadline)  // Larger font for club abbr to stand out
                        .frame(minWidth: 40, alignment: .leading)
                    Text("\(data.avgDistance, specifier: "%.0f")")
                        .frame(minWidth: 40, alignment: .center)
                    Text("\(data.minDistance, specifier: "%.0f")")
                        .frame(minWidth: 40, alignment: .center)
                    Text("\(data.maxDistance, specifier: "%.0f")")
                        .frame(minWidth: 40, alignment: .center)
                    Text("\(abs(data.avgDeviation), specifier: "%.0f") \(data.avgDeviation < 0 ? "L" : "R") ")
                        .frame(minWidth: 60, alignment: .center)
                    Circle()
                        .fill(scoreColor(for: data.score))
                        .frame(width: 24, height: 24)  // Smaller circle
                        .overlay(Text("\(data.score, specifier: "%.0f")").font(.caption2).foregroundColor(.white))
                        .frame(minWidth: 50, alignment: .center)
                }
                .font(.caption2)  // Smaller font for other cells
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)  // Reduced vertical padding
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .shadow(radius: 1)  // Lighter shadow
            }
        }
        .padding(.vertical, 10)  // Reduced overall padding
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView(title: "Club Data")
                
                if sessions.isEmpty || allShots.isEmpty {
                    Text("No club data yet. Complete tests to build stats.")
                        .foregroundColor(.secondaryText)
                        .padding()
                } else {
                    ScrollView {
                        avgDistanceChart
                        
                        clubStatsTable
                    }
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
        }
        .onAppear {
            loadSessions()
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.array(forKey: "testSessions") as? [[String: Any]] {
            sessions = data.compactMap { TestSession(from: $0) }.sorted(by: { $0.date < $1.date })
        }
    }
    
    // Club abbreviations like in the image
    private func clubAbbr(for club: String) -> String {
        switch club {
        case "Driver": return "Dr"
        case "3 Wood": return "3w"
        case "5 Wood": return "5w"
        case "7 Wood": return "7w"
        case "3 Hybrid": return "3h"
        case "4 Hybrid": return "4h"
        case "5 Hybrid": return "5h"
        case "3 Iron": return "3i"
        case "4 Iron": return "4i"
        case "5 Iron": return "5i"
        case "6 Iron": return "6i"
        case "7 Iron": return "7i"
        case "8 Iron": return "8i"
        case "9 Iron": return "9i"
        case "Pitching Wedge": return "PW"
        case "Gap Wedge": return "GW"
        case "Sand Wedge": return "SW"
        case "Lob Wedge": return "LW"
        case "Putter": return "P"
        default: return club.prefix(2).uppercased()
        }
    }
}
