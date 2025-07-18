//
//  AddClubView.swift
//  GolfTest
//
//  Created by Ben Hester on 17/07/2025.
//

import SwiftUI

struct AddClubView: View {
    let clubCategories: [ClubCategory]
    @Binding var selectedClubs: Set<String>
    let existingClubs: [String] // To disable already added clubs
    @Environment(\.dismiss) var dismiss
    
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
                            .disabled(existingClubs.contains(club)) // Disable if already in bag
                            .foregroundColor(existingClubs.contains(club) ? .secondaryText : .primaryText)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Clubs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                    .disabled(selectedClubs.isEmpty) // Optional: disable if nothing selected
                }
            }
        }
        .background(Color.appBackground)
    }
}
