//
//  words.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import Foundation

final class Words {
    static let shared = Words()
    let allWords: [String]

    private init() {
        // Load words.txt from your bundle
        guard let url = Bundle.main.url(forResource: "words", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8)
        else {
            fatalError("words.txt not found or couldn’t be read")
        }

        allWords = content
            .components(separatedBy: .newlines)
            .filter { $0.count == 5 }
    }
}
