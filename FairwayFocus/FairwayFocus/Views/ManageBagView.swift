import SwiftUI

struct ManageBagView: View {
    let clubCategories: [ClubCategory]
    @State private var selectedClubs: Set<String>
    let onSave: (Set<String>) -> Void  // Callback to save changes
    @Environment(\.dismiss) var dismiss
    
    init(clubCategories: [ClubCategory], selectedClubs: Binding<Set<String>>, onSave: @escaping (Set<String>) -> Void) {
        self.clubCategories = clubCategories
        self._selectedClubs = State(initialValue: selectedClubs.wrappedValue)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(clubCategories) { category in
                    Section(header: Text(category.name).font(.headline).foregroundColor(.primaryText)) {
                        ForEach(category.clubs, id: \.self) { club in
                            Button(action: {
                                if selectedClubs.contains(club) {
                                    selectedClubs.remove(club)
                                } else {
                                    selectedClubs.insert(club)
                                }
                            }) {
                                HStack {
                                    Text(club)
                                        .foregroundColor(.primaryText)
                                    Spacer()
                                    if selectedClubs.contains(club) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.primaryGreen)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Manage Bag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(selectedClubs)
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .background(Color.appBackground)
    }
}
