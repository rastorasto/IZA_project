//
//  ContentView.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        TabView {
            NavigationStack {
                GameView()
                    .navigationTitle("Word Guessing Game")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Play", systemImage: "text.bubble")
            }
            NavigationStack {
                StatsView()
                }
                        .tabItem {
                            Label("Stats", systemImage: "list.clipboard")
            }
            
            NavigationStack {
                // List all bundled words
                List(Words.shared.allWords, id: \.self) { word in
                    Text(word)
                }
                .navigationTitle("All Words")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Words", systemImage: "text.book.closed")
            }
        }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
