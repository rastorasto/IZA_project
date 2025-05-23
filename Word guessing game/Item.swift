//
//  Item.swift
//  Word guessing game
//
//  Created by Rastislav Uhliar on 23.05.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
