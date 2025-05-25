//
//  statsview.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 24.05.2025.
//

import SwiftUI

struct StatsView: View {
    @AppStorage("gamesWon") var gamesWon = 0
    @AppStorage("gamesPlayed") var gamesPlayed = 0
    @AppStorage("guessedWords") var guessedWordsData: String = "[]"

    var guessedWords: [String] {
        (try? JSONDecoder().decode([String].self, from: Data(guessedWordsData.utf8))) ?? []
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("🏆 Games Won: \(gamesWon)")
                Text("🎮 Total Guesses: \(gamesPlayed)")

                Divider()

                Text("📜 Recent Guesses:")
                    .font(.headline)

                if guessedWords.isEmpty {
                    Text("No guesses yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(guessedWords.suffix(5).reversed(), id: \.self) { word in
                        Text(word)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Stats")
        }
    }
}
