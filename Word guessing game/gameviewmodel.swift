//
//  gameviewmodel.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//
import SwiftUI

enum TileState {
    case empty, correct, present, absent

    var color: Color {
        switch self {
        case .empty: return Color(.systemGray6)
        case .correct: return .green
        case .present: return .yellow
        case .absent:  return .gray
        }
    }
}

class GameViewModel: ObservableObject {
    @Published var grid = Array(repeating: Array(repeating: "", count: 5), count: 5)
    @Published var states = Array(repeating: Array(repeating: TileState.empty, count: 5), count: 5)
    @Published var word: String
    @Published var currentRow = 0
    @Published var currentCol = 0
    @Published var isGameWon = false
    @Published var showInvalidWordAlert = false
    @Published var isGameOver = false

    
    @AppStorage("gamesWon") var gamesWon = 0
    @AppStorage("gamesPlayed") var gamesPlayed = 0
    @AppStorage("guessedWords") var guessedWordsData: String = "[]"

    var guessedWords: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(guessedWordsData.utf8))) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                guessedWordsData = String(decoding: data, as: UTF8.self)
            }
        }
    }

    init() {
        let words = Words.shared.allWords
        word = words.randomElement()?.uppercased() ?? "APPLE"
        print(word)
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: "", count: 5), count: 5)
        states = Array(repeating: Array(repeating: TileState.empty, count: 5), count: 5)
        currentRow = 0
        currentCol = 0
        isGameWon = false
        isGameOver = false
        showInvalidWordAlert = false
        
        // Pick a new random word
        let words = Words.shared.allWords
        word = words.randomElement()?.uppercased() ?? "APPLE"
    }

    func deleteLastLetter() {
        print("Delete called - current row: \(currentRow), col: \(currentCol)")
        guard currentCol > 0, !isGameOver else {
            print("Cannot delete - col: \(currentCol), gameOver: \(isGameOver)")
            return
        }
        currentCol -= 1
        grid[currentRow][currentCol] = ""
        print("After delete - grid: \(grid[currentRow])")
    }
    
    func insert(letter: String) {
        // Debug print to see what's being inserted
        print("Inserting letter: '\(letter)' at row: \(currentRow), col: \(currentCol)")
        
        guard currentRow < 5, !isGameOver else {
            print("Game over or invalid row")
            return
        }

//        if letter == "⌫" { // Handle backspace (delete)
//            deleteLastLetter()
//            return
//        }

        guard currentCol < 5 else {
            print("Column full")
            return
        }
        
        grid[currentRow][currentCol] = letter.uppercased()
        print("Grid updated: \(grid[currentRow])")
        currentCol += 1

        if currentCol == 5 {
            let guess = grid[currentRow].joined().uppercased()
            print("Complete word: \(guess)")
            if Words.shared.allWords.contains(guess.lowercased()) {
                checkCurrentRow()
            } else {
                showInvalidWordAlert = true
                for _ in 0..<5 {
                    deleteLastLetter()
                }
            }
        }
    }

    func checkCurrentRow() {
        let guess = grid[currentRow].joined()
        let result = evaluate(guess: guess, against: word)
        states[currentRow] = result

        // Save guess and increment games played
        var updatedGuesses = guessedWords
        updatedGuesses.append(guess)
        guessedWords = updatedGuesses
        gamesPlayed += 1

        if result.allSatisfy({ $0 == .correct }) {
            isGameWon = true
            isGameOver = true
            gamesWon += 1
        } else if currentRow >= 4 {
            // Game over - used all attempts
            isGameOver = true
        } else {
            currentRow += 1
            currentCol = 0
        }
    }
    

    func evaluate(guess: String, against answer: String) -> [TileState] {
        var result = [TileState](repeating: .absent, count: 5)
        var freq = Dictionary(answer.map { ($0, 1) }, uniquingKeysWith: +)

        // First pass: correct
        for i in 0..<5 {
            if guess[i] == answer[i] {
                result[i] = .correct
                freq[guess[i]]! -= 1
            }
        }

        // Second pass: present
        for i in 0..<5 {
            if result[i] == .correct { continue }
            let ch = guess[i]
            if freq[ch, default: 0] > 0 {
                result[i] = .present
                freq[ch]! -= 1
            }
        }

        return result
    }
}

private extension String {
    subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }
}
