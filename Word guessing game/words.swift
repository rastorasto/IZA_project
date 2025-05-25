//
//  words.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import Foundation

// Function that loads the words from the txt file
// The words.txt contains the words from https://gist.github.com/shmookey/b28e342e1b1756c4700f42f17102c2ff
final class Words {
    static let shared = Words()
    let allWords: [String] // Array to store the words

    private init() {
        // Load words.txt
        guard let url = Bundle.main.url(forResource: "words", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8)
        else {
            fatalError("words.txt not found or couldn’t be read")
        }

        allWords = content // Splits the words by new lines
            .components(separatedBy: .newlines)
    }
}
