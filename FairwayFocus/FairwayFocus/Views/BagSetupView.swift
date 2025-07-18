import SwiftUI

struct BagSetupView: View {
    // Predefined club types categorized
    let clubCategories: [ClubCategory] = [
        ClubCategory(name: "Drivers", clubs: ["Driver"]),
        ClubCategory(name: "Woods", clubs: ["3 Wood", "5 Wood", "7 Wood"]),
        ClubCategory(name: "Hybrids", clubs: ["3 Hybrid", "4 Hybrid", "5 Hybrid"]),
        ClubCategory(name: "Irons", clubs: ["3 Iron", "4 Iron", "5 Iron", "6 Iron", "7 Iron", "8 Iron", "9 Iron"]),
        ClubCategory(name: "Wedges", clubs: ["Pitching Wedge", "Gap Wedge", "Sand Wedge", "Lob Wedge"])
    ]
    
    // Define club order for sorting (from driver to putter)
    let clubOrder: [String] = [
        "Driver", "3 Wood", "5 Wood", "7 Wood",
        "3 Hybrid", "4 Hybrid", "5 Hybrid",
        "3 Iron", "4 Iron", "5 Iron", "6 Iron", "7 Iron", "8 Iron", "9 Iron",
        "Pitching Wedge", "Gap Wedge", "Sand Wedge", "Lob Wedge",
    ]
    
    // User's bag: stored as an array of selected clubs
    @State private var userBag: [String] = {
        if let data = UserDefaults.standard.data(forKey: "userBagData") {
            if let bag = try? JSONDecoder().decode([String].self, from: data) {
                return bag
            }
        }
        return []
    }()
    
    // State for managing bag
    @State private var showingManageBagSheet = false
    
    // Sorted bag for display
    private var sortedUserBag: [String] {
        userBag.sorted { (club1, club2) -> Bool in
            let index1 = clubOrder.firstIndex(of: club1) ?? Int.max
            let index2 = clubOrder.firstIndex(of: club2) ?? Int.max
            return index1 < index2
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Your Golf Bag")
            
            // List of clubs in bag
            List {
                Section(header: Text("Clubs in Your Bag").font(.headline).foregroundColor(.primaryText)) {
                    if userBag.isEmpty {
                        Text("No clubs added yet. Tap 'Manage Bag' to start.")
                            .foregroundColor(.secondaryText)
                            .italic()
                    } else {
                        ForEach(sortedUserBag, id: \.self) { club in
                            HStack {
                                Image(systemName: clubIcon(for: club))
                                    .foregroundColor(.accentGreen)
                                Text(club)
                                    .foregroundColor(.primaryText)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            // Manage Bag Button
            Button(action: {
                showingManageBagSheet = true
            }) {
                Text("Manage Bag")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .background(Color.appBackground)
        .sheet(isPresented: $showingManageBagSheet) {
            ManageBagView(clubCategories: clubCategories, selectedClubs: .constant(Set(userBag)), onSave: { newSelected in
                userBag = Array(newSelected).sorted { (club1, club2) -> Bool in
                    let index1 = clubOrder.firstIndex(of: club1) ?? Int.max
                    let index2 = clubOrder.firstIndex(of: club2) ?? Int.max
                    return index1 < index2
                }
                saveUserBag()
            })
        }
        .onChange(of: userBag) { _ in
            saveUserBag()  // Save whenever bag changes
        }
    }
    
    private func saveUserBag() {
        if let data = try? JSONEncoder().encode(userBag) {
            UserDefaults.standard.set(data, forKey: "userBagData")
        }
    }
    
    private func clubIcon(for club: String) -> String {
        // Simple icon mapping; you can replace with custom images later
        if club.contains("Driver") { return "figure.golf" }
        if club.contains("Wood") { return "figure.golf" }
        if club.contains("Hybrid") { return "figure.golf" }
        if club.contains("Iron") { return "figure.golf" }
        if club.contains("Wedge") { return "figure.golf" }
        return "questionmark"
    }
}
