//
//  statsview.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 24.05.2025.
//

import SwiftUI

struct StatsView: View {
    // Valiables in persistent storage
    @AppStorage("gamesWon") var gamesWon = 0
    @AppStorage("gamesPlayed") var gamesPlayed = 0
    @AppStorage("guessedWords") var guessedWordsData: String = "[]"

    // Decodes the json into list of gussed words
    var guessedWords: [String] {
        (try? JSONDecoder().decode([String].self, from: Data(guessedWordsData.utf8))) ?? []
    }

    // Calculates the win rate percentage
    var winRate: Double {
        gamesPlayed > 0 ? (Double(gamesWon) / Double(gamesPlayed)) * 100 : 0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {

                // Top section
                VStack {
                    Text("🏆 \(gamesWon)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.yellow)
                    Text("Games Won")
                        .font(.headline)
                }

                // Displays the total games and win rate
                VStack(spacing: 5) {
                    Text("🎯 Total Games: \(gamesPlayed)")
                    Text("📈 Win Rate: \(Int(winRate))%")
                }
                .font(.subheadline)
                .foregroundColor(.gray)

                Divider()

                // Displays the last winning words in scrollable list
                Text("⭐️ Last Winning Words")
                    .font(.title3)
                    .bold()
                    .padding(.top)

                if guessedWords.isEmpty {
                    Text("No wins yet.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(guessedWords.reversed(), id: \.self) { word in
                                Text(word)
                                    .padding(.horizontal)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Stats")
        }
    }
}
