//
//  TriviaDifficulty.swift
//  TrivaTok
//
//  Created by Jaime Klau on 10/27/26.
//


import Foundation

enum TriviaDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String {
        rawValue
    }

    var title: String {
        rawValue.capitalized
    }
}
