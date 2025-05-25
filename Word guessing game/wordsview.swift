//
//  wordsview.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 25.05.2025.
//

import SwiftUI

// Displays the dictionary of the words that are available in the game
struct WordsListView: View {
    var body: some View {
        // List showing each word
        List(Words.shared.allWords, id: \.self) { word in
            Text(word.uppercased())
                .font(.system(.body, design: .monospaced))
        }
        .navigationTitle("Dictionary")
        .navigationBarTitleDisplayMode(.inline)
    }
}
