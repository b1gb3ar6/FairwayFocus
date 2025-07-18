import SwiftUI
import Charts  // For progress charts in history; used here for per-test visuals if needed

struct TestView: View {
    @State private var userBag: [String] = []  // Use @State and load from UserDefaults
    @State private var selectedClub: String? = nil
    @State private var shots: [Shot] = []  // Shots for this test session
    @State private var distanceInput: String = ""
    @State private var deviationInput: String = ""  // Absolute deviation value
    @State private var deviationDirection: String = "Right"  // Default to Right (positive)
    @State private var showingResults = false
    @State private var testScore: Double = 0.0
    @State private var insights: String = ""
    @State private var numShots: String = ""  // Input for number of shots
    @State private var minYardage: String = ""
    @State private var maxYardage: String = ""
    @State private var targets: [Double] = []  // Random targets generated
    @State private var currentShotIndex: Int = 0  // Track current shot being entered
    @State private var testStarted: Bool = false
    @State private var showShotScore: Bool = false  // Toggle to show per-shot score ring
    @State private var currentShotScore: Double = 0.0  // Score for the just-submitted shot
    
    // Define club order for sorting (same as BagSetupView)
    let clubOrder: [String] = [
        "Driver", "3 Wood", "5 Wood", "7 Wood",
        "3 Hybrid", "4 Hybrid", "5 Hybrid",
        "3 Iron", "4 Iron", "5 Iron", "6 Iron", "7 Iron", "8 Iron", "9 Iron",
        "Pitching Wedge", "Gap Wedge", "Sand Wedge", "Lob Wedge",
        "Putter"
    ]
    
    // Sorted bag for Picker
    private var sortedUserBag: [String] {
        userBag.sorted { (club1, club2) -> Bool in
            let index1 = clubOrder.firstIndex(of: club1) ?? Int.max
            let index2 = clubOrder.firstIndex(of: club2) ?? Int.max
            return index1 < index2
        }
    }
    
    // Traffic light color for score
    private func scoreColor(for score: Double) -> Color {
        if score > 80 {
            return Color.green  // High: Green
        } else if score > 50 {
            return Color.yellow  // Medium: Yellow
        } else {
            return Color.red  // Low: Red
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView(title: "Test")
                
                if userBag.isEmpty {
                    Text("Setup your bag first to start a test.")
                        .foregroundColor(.secondaryText)
                        .padding()
                } else if !testStarted {
                    // Initial setup: Num shots and range
                    Form {
                        Section(header: Text("Test Setup")) {
                            TextField("How many shots?", text: $numShots)
                                .keyboardType(.numberPad)
                            TextField("Min yardage", text: $minYardage)
                                .keyboardType(.decimalPad)
                            TextField("Max yardage", text: $maxYardage)
                                .keyboardType(.decimalPad)
                            Button("Start Test") {
                                generateTargets()
                            }
                            .disabled(numShots.isEmpty || minYardage.isEmpty || maxYardage.isEmpty)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGreen)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        }
                    }
                } else {
                    // Centered target display
                    VStack {
                        if currentShotIndex < targets.count && !showShotScore {
                            Text("Shot \(currentShotIndex + 1)")
                                .font(.title2)
                                .foregroundColor(.primaryText)
                            
                            Text(String(format: "%.0f", targets[currentShotIndex]))
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.primaryGreen)
                        } else if showShotScore {
                            // Show per-shot score as large number with traffic light color
                            Text(String(format: "%.0f", currentShotScore))
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(scoreColor(for: currentShotScore))
                                .padding(.bottom, 40)  // Added padding between score and button
                            
                            Button(currentShotIndex < targets.count ? "Next Shot" : "Finish Test") {
                                showShotScore = false
                                if currentShotIndex >= targets.count {
                                    calculateResults()
                                    saveTestSession()
                                    showingResults = true
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.primaryGreen)
                            .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.appBackground)
                    
                    if currentShotIndex < targets.count && !showShotScore {
                        // Inputs below the target display
                        Form {
                            Picker("Club Used", selection: $selectedClub) {
                                ForEach(sortedUserBag, id: \.self) { club in
                                    Text(club).tag(club as String?)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            TextField("Actual Carry (yards)", text: $distanceInput)
                                .keyboardType(.decimalPad)
                            
                            HStack {
                                TextField("Deviation (feet)", text: $deviationInput)
                                    .keyboardType(.decimalPad)
                                
                                Picker("Direction", selection: $deviationDirection) {
                                    Text("Left").tag("Left")
                                    Text("Right").tag("Right")
                                }
                                .pickerStyle(SegmentedPickerStyle())  // Segmented for Left/Right
                            }
                            
                            Button("Submit Shot") {
                                if let dist = Double(distanceInput), let devAbs = Double(deviationInput) {
                                    let dev = deviationDirection == "Left" ? -devAbs : devAbs
                                    let shot = Shot(club: selectedClub ?? "Unknown", distance: dist, deviation: dev)
                                    shots.append(shot)
                                    distanceInput = ""
                                    deviationInput = ""
                                    selectedClub = nil
                                    
                                    // Calculate per-shot score
                                    let diff = abs(shot.distance - targets[currentShotIndex])
                                    let devPenalty = abs(shot.deviation)
                                    currentShotScore = max(0, 100 - (diff * 2) - devPenalty)
                                    
                                    // Show score
                                    showShotScore = true
                                    currentShotIndex += 1
                                }
                            }
                            .disabled(selectedClub == nil || distanceInput.isEmpty || deviationInput.isEmpty)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGreen)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingResults) {
                VStack(spacing: 20) {
                    Text("Test Results")
                        .font(.largeTitle)
                        .bold()
                    
                    Text(String(format: "%.0f", testScore))
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(scoreColor(for: testScore))
                    
                    Text("Insights: \(insights)")
                        .font(.body)
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button("Start New Test") {
                        showingResults = false
                        resetTest()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryGreen)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            // Force reload on appear to ensure sync; match BagSetupView's JSON storage
            if let data = UserDefaults.standard.data(forKey: "userBagData") {
                userBag = (try? JSONDecoder().decode([String].self, from: data)) ?? []
            } else {
                userBag = []
            }
        }
    }
    
    private func generateTargets() {
        guard let num = Int(numShots), let minY = Double(minYardage), let maxY = Double(maxYardage), minY < maxY else { return }
        targets = (0..<num).map { _ in Double.random(in: minY...maxY) }
        testStarted = true
        currentShotIndex = 0
        shots = []
        showShotScore = false
    }
    
    private func calculateResults() {
        var totalScore: Double = 0.0
        for i in 0..<shots.count {
            let diff = abs(shots[i].distance - targets[i])
            let devPenalty = abs(shots[i].deviation)
            let shotScore = max(0, 100 - (diff * 2) - devPenalty)
            totalScore += shotScore
        }
        testScore = totalScore / Double(shots.count)
        insights = testScore > 80 ? "Excellent performance!" : (testScore > 50 ? "Good, but room for improvement." : "Focus on accuracy and club selection.")
    }
    
    private func saveTestSession() {
        let session = TestSession(date: Date(), score: testScore, insights: insights, shots: shots)
        var sessions = UserDefaults.standard.array(forKey: "testSessions") as? [[String: Any]] ?? []
        sessions.append(session.toDictionary())
        UserDefaults.standard.set(sessions, forKey: "testSessions")
    }
    
    private func resetTest() {
        numShots = ""
        minYardage = ""
        maxYardage = ""
        targets = []
        shots = []
        testStarted = false
        currentShotIndex = 0
        testScore = 0.0
        insights = ""
        showShotScore = false
    }
}
