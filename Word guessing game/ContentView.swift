//
//  ContentView.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        TabView {
            // Game tab
            NavigationStack {
                GameView()
                    .navigationTitle("Word Guessing Game")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Play", systemImage: "gamecontroller")
            }
            
            // Stats tab
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            
            // Dictionary tab
            NavigationStack {
                WordsListView()
            }
            .tabItem {
                Label("Words", systemImage: "book.closed")
            }
        }
  }
}

// This is here to make the preview canvas in xcode work
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
