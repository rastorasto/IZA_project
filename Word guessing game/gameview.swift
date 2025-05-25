//
//  gameview.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import SwiftUI

// Main game view
struct GameView: View {
    @StateObject private var vm = GameViewModel()
    @State private var showHelp = false // Help menu
    @FocusState private var textFieldFocused: Bool // Keyboard focus information
    @State private var currentInput = "" // Stores current input from the user
    private let columns = Array(repeating: GridItem(.flexible()), count: 5) // Game grid information
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
//                Text("Answer: \(vm.word)") // Shows the word that the user needs to guess for debugging purposes
//                    .font(.headline)

                LazyVGrid(columns: columns, spacing: 5) { // Creates all the game tiles
                    ForEach(0..<25) { idx in
                        let row = idx / 5
                        let col = idx % 5
                        Tile(letter: vm.grid[row][col], state: vm.states[row][col])
                    }
                }

                if vm.isGameOver { // When the game is over
                    VStack(spacing: 10) {
                        // Displays the message of the game status
                        Text(vm.isGameWon ? "🎉 You won!" : "😞 Game Over")
                            .font(.title2)
                            .padding(.top)

                        // Shows new game button
                        Button(action: {
                            vm.resetGame()
                            currentInput = ""
                        }) {
                            Text("New Game")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }

                // Hidden textfield that is used for storing user input
                TextField("Type here", text: $currentInput)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .focused($textFieldFocused)
                    .opacity(0.01)
                    .frame(width: 1, height: 1)
                    .padding(.zero)
                    .onChange(of: currentInput) { oldValue, newValue in // Calls function that manages the tiles with letters
                        handleInputChange(oldValue: oldValue, newValue: newValue)
                    }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                textFieldFocused.toggle() // On screen tap toggle keyboard
            }
            .onChange(of: vm.isGameOver) { _, isGameOver in // When the game is over hide the keyboard
                if isGameOver {
                    textFieldFocused = false
                }
            }
            .alert("Not a valid word", isPresented: $vm.showInvalidWordAlert) { // Invalid word popup
                Button("OK", role: .cancel) { }
            }

            // Help button
            Button(action: {
                showHelp = true
            }) {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                    .padding(16)
            }
        }
        .alert("How to Play", isPresented: $showHelp) {
            Button("Got it!", role: .cancel) { }
        } message: {
            Text("""
            Tap on the screen to open the keyboard.
            Think of a 5 letter word and type it
            Colored tiles show correctness:
            🟩 = correct, 🟨 = correct but wrong possition, ⬜ = not in word.
            Click on the stats in the bottom bar to show your statistics
            All available words are shown in the Words tab
            """)
        }
    }

    private func handleInputChange(oldValue: String, newValue: String) { // Handles input from the user
        guard oldValue != newValue else { return }

        let oldCount = oldValue.count
        let newCount = newValue.count

        if newCount == 5 { // If there are 5 letters it will go to another row therefore the current input is deleted
            currentInput.removeAll()
        }

        if newCount > oldCount {
            // If letters were added add them ( there should be only one but just to be safe try to add all of the added letter )
            let addedString = String(newValue.suffix(newCount - oldCount))
            for char in addedString.uppercased() where char.isLetter {
                vm.insert(letter: String(char))
            }
        } else if newCount < oldCount {
            // If user removed a letter remove it from the tile
                vm.deleteLastLetter()
        }
    }
}

// Tile structure for the letters
struct Tile: View {
    let letter: String
    let state: TileState

    @State private var animateBounce = false // Bounce animation flag

    var body: some View {
        Text(letter)
            .font(.title)
            .bold()
            .frame(width: 60, height: 60)
            .background(state.color)
            .foregroundColor(state.textColor)
            .cornerRadius(8)
            .scaleEffect(animateBounce ? 1.2 : 1.0)
            .animation(.interpolatingSpring(stiffness: 200, damping: 5), value: animateBounce) // Bouncing animation
            .onChange(of: state) { _, _ in
                animateBounce = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animateBounce = false
                }
            }
    }
}
