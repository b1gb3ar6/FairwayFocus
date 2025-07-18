import SwiftUI
import Charts

struct HistoryView: View {
    @State private var sessions: [TestSession] = []  // Loaded from UserDefaults
    
    // Computed properties for recent sessions and trend
    private var recentSessions: [TestSession] {
        Array(sessions.suffix(5))
    }
    
    private var recentAverage: Double {
        guard !recentSessions.isEmpty else { return 0.0 }
        let total = recentSessions.reduce(0.0) { $0 + $1.score }
        return total / Double(recentSessions.count)
    }
    
    private var trend: (String, Color, String) {  // (description, color, arrow symbol)
        guard recentSessions.count >= 2 else {
            return ("Stable", Color.gray, "arrow.right")  // No trend data
        }
        
        // Simple linear regression for slope
        let n = Double(recentSessions.count)
        let x = Array(1...recentSessions.count).map { Double($0) }  // Indices 1 to n
        let y = recentSessions.map { $0.score }
        
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).reduce(0) { $0 + $1.0 * $1.1 }
        let sumX2 = x.reduce(0) { $0 + $1 * $1 }
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        
        if slope > 0.5 {
            return ("Improving", Color.green, "arrow.up")  // Green for improving
        } else if slope < -0.5 {
            return ("Declining", Color.red, "arrow.down")  // Red for declining
        } else {
            return ("Stable", Color.yellow, "arrow.right")  // Yellow for stable
        }
    }
    
    // Summary based on recent sessions
    private var summary: (highlight: String, workOn: String, improvements: String) {
        guard !recentSessions.isEmpty else {
            return ("No data yet.", "Start testing to build insights.", "Complete more sessions for personalized tips.")
        }
        
        let avgScore = recentAverage
        let bestScore = recentSessions.max(by: { $0.score < $1.score })?.score ?? 0.0
        
        let highlight = avgScore > 80 ? "Strong consistency with an average of \(String(format: "%.1f", avgScore)). Best session: \(String(format: "%.1f", bestScore))." :
                        avgScore > 50 ? "Solid foundation; peaking at \(String(format: "%.1f", bestScore))." :
                        "Building experience; highlight session at \(String(format: "%.1f", bestScore))."
        
        let workOn = avgScore < 50 ? "Focus on overall accuracy and deviation control." :
                     avgScore < 80 ? "Refine club selection and distance consistency." :
                     "Maintain high performance; minor tweaks for perfection."
        
        let improvements: String
        switch true {
        case avgScore < 50:
            improvements = "Practice alignment drills: Use alignment sticks at the range. Work on tempo with metronome swings. Consider a lesson for swing path analysis."
        case avgScore < 80:
            improvements = "Incorporate yardage gaps testing: Hit 10 shots per club to map distances. Use video analysis for posture checks. Strengthen core for better stability."
        default:
            improvements = "Advanced drills: Simulate on-course pressure with random targets. Track stats in a journal. Experiment with equipment tweaks like grip size."
        }
        
        return (highlight, workOn, improvements)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: 100)  // Placeholder to offset content below the fixed header
                        
                        if sessions.isEmpty {
                            Text("No test history yet. Complete a test to track progress.")
                                .foregroundColor(.secondaryText)
                                .padding()
                        } else {
                            // Recent Average section
                            VStack {
                                Text("Recent Average")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primaryText)
                                
                                Text("\(recentAverage, specifier: "%.1f")")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(trend.1)  // Color based on trend
                                
                                HStack {
                                    Image(systemName: trend.2)  // Arrow icon
                                        .foregroundColor(trend.1)
                                    Text(trend.0)
                                        .foregroundColor(trend.1)
                                }
                                .font(.subheadline)
                            }
                            .padding()
                            
                            // Chart for scores over time (only recent 5)
                            Chart {
                                ForEach(recentSessions) { session in
                                    LineMark(
                                        x: .value("Date", session.date),
                                        y: .value("Score", session.score)
                                    )
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            
                            // Summary of recent sessions
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Sessions Summary")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)
                                
                                Text("Highlight: \(summary.highlight)")
                                    .foregroundColor(.secondaryText)
                                
                                Text("Work On: \(summary.workOn)")
                                    .foregroundColor(.secondaryText)
                                
                                Text("Improvement Tips: \(summary.improvements)")
                                    .foregroundColor(.secondaryText)
                            }
                            .padding()
                        }
                    }
                }
                .background(Color.appBackground)
                
                HeaderView(title: "History")
                    .frame(height: 100)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadSessions()
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.array(forKey: "testSessions") as? [[String: Any]] {
            sessions = data.compactMap { TestSession(from: $0) }.sorted(by: { $0.date < $1.date })  // Sort ascending by date
        }
    }
}
