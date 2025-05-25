//
//  gameview.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var vm = GameViewModel()
    @FocusState private var textFieldFocused: Bool
    @State private var currentInput = ""
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        VStack(spacing: 20) {
//            Text("Answer: \(vm.word)")
//                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0..<25) { idx in
                    let row = idx / 5
                    let col = idx % 5
                    LetterBox(letter: vm.grid[row][col], state: vm.states[row][col])
                }
            }
            
            // Hidden but functional TextField
            TextField("Type here", text: $currentInput)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .focused($textFieldFocused)
                .opacity(0.01)
                .frame(width: 1, height: 1)
                .padding(.zero)
                .onChange(of: currentInput) { oldValue, newValue in
                    handleInputChange(oldValue: oldValue, newValue: newValue)
                }
                .onChange(of: currentInput) { _, newValue in
                    // Limit input to 5 characters
                    if newValue.count > 5 {
                        currentInput = String(newValue.prefix(5))
                    }
                }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            print("Tap detected!") // Debug check
            textFieldFocused.toggle()
        }
        .alert("🎉 You won!", isPresented: $vm.isGameWon) {
            Button("OK", role: .cancel) { }
        }
        .alert("Not a valid word", isPresented: $vm.showInvalidWordAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            textFieldFocused = true
        }
    }
    
    private func handleInputChange(oldValue: String, newValue: String) {
        guard oldValue != newValue else { return }
        
        let oldCount = oldValue.count
        let newCount = newValue.count
        
        print("current input is \(currentInput)")
        if(newCount == 5){
            currentInput.removeAll()
        }
        print("current input is \(currentInput)")
        if newCount > oldCount {
            // Insert new characters
            let addedString = String(newValue.suffix(newCount - oldCount))
            for char in addedString.uppercased() where char.isLetter {
                vm.insert(letter: String(char))
            }
        } else if newCount < oldCount {
            // Delete characters
            print("deleteeeee")
            let removedCount = oldCount - newCount
            for _ in 0..<removedCount {
                vm.deleteLastLetter()
            }
        }}
    }

struct LetterBox: View {
    let letter: String
    let state: TileState

    var body: some View {
        Text(letter)
            .font(.title)
            .bold()
            .frame(width: 50, height: 50)
            .background(state.color)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
