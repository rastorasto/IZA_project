//
//  gameviewmodel.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//
import SwiftUI

// State of the letter tiles
enum TileState {
    case empty, correct, present, absent // Enum for all the options

    // Returns the color for each tile
    var color: Color {
        switch self {
        case .empty: return Color(.systemGray4)
        case .correct: return .green
        case .present: return .yellow
        case .absent:  return .gray
        }
    }
    var textColor: Color { // Depending on the system theme light/dark the text color is changed
        switch self {
        case .empty:
            return .primary
        default:
            return .black
        }
    }
}

class GameViewModel: ObservableObject {
    @Published var grid = Array(repeating: Array(repeating: "", count: 5), count: 5) // Grid of tiles
    @Published var states = Array(repeating: Array(repeating: TileState.empty, count: 5), count: 5) // States of the tiles
    @Published var word: String // The word that the user is guessing
    @Published var currentRow = 0
    @Published var currentCol = 0
    // Variables that hold the game state
    @Published var isGameWon = false
    @Published var showInvalidWordAlert = false
    @Published var isGameOver = false

    
    // Persistent storage that hold the variables used in statistics tab
    @AppStorage("gamesWon") var gamesWon = 0
    @AppStorage("gamesPlayed") var gamesPlayed = 0
    @AppStorage("guessedWords") var guessedWordsData: String = "[]"

    var guessedWords: [String] { // Accessing guessed words array
        get {
            (try? JSONDecoder().decode([String].self, from: Data(guessedWordsData.utf8))) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                guessedWordsData = String(decoding: data, as: UTF8.self)
            }
        }
    }

    init() { // Initializer that randomly chooses the word
        let words = Words.shared.allWords
        word = words.randomElement()?.uppercased() ?? "APPLE" // Fallback word should not happen but just to sure
        print(word) // Prints the word into console for debugging
    }
    
    func resetGame() { // New game
        // Cleares the tiles and sets the variables to start
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
        print(word) // Prints the word into console for debugging
    }

    // Removes the last letter from the tiles
    func deleteLastLetter() {
        guard currentCol > 0, !isGameOver else {
            return
        }
        currentCol -= 1
        grid[currentRow][currentCol] = ""
    }
    
    // Inserts the letter into the tiles
    func insert(letter: String) {
        guard currentRow < 5, !isGameOver else {
            return
        }

        guard currentCol < 5 else {
            return
        }
        
        grid[currentRow][currentCol] = letter.uppercased()
        currentCol += 1

        if currentCol == 5 { // If it was the last letter check the row
            let guess = grid[currentRow].joined().uppercased()
            if Words.shared.allWords.contains(guess.lowercased()) {
                // If the word is valid check if it matches the guessed word
                checkCurrentRow()
            } else {
                // If the letter is not valid remove all the letters from tiles and show the popup message
                showInvalidWordAlert = true
                for _ in 0..<5 {
                    deleteLastLetter()
                }
            }
        }
    }

    // Checks the current row
    func checkCurrentRow() {
        let guess = grid[currentRow].joined()
        let result = evaluate(guess: guess, against: word)
        states[currentRow] = result

        if result.allSatisfy({ $0 == .correct }) { // If all the letters match the game is won, the data is added to the statistics
            isGameWon = true
            isGameOver = true
            gamesWon += 1
            gamesPlayed += 1
            saveGuess(guess)
        } else if currentRow >= 4 { // If the user used all rows and he lost save the statistics and show the message
            isGameOver = true
            gamesPlayed += 1
            saveGuess(word)
        } else { // Else go to the next row
            currentRow += 1
            currentCol = 0
        }
    }



    // Adds the guess into the persistent storage
    private func saveGuess(_ guess: String) {
        var updatedGuesses = guessedWords
        updatedGuesses.append(guess.uppercased())
        guessedWords = updatedGuesses
    }

    

    // Evaluates the row
    func evaluate(guess: String, against answer: String) -> [TileState] {
        var result = [TileState](repeating: .absent, count: 5)
        var freq = Dictionary(answer.map { ($0, 1) }, uniquingKeysWith: +)

        // First checks for the correct letters with correct position
        for i in 0..<5 {
            if guess[i] == answer[i] {
                result[i] = .correct
                freq[guess[i]]! -= 1
            }
        }

        // Then checks for letters that are present in the guessed word
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

private extension String { // String extension to allow easy access to individual characters 
    subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }
}
