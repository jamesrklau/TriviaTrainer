//
//  QuestionExplanation.swift
//  TrivaTok
//
//  Created by Jaime Klau on 11/1/26.
//

import Foundation

struct QuestionExplanation {
    let explanation: String
    let reasoningSteps: [ReasoningStep]
    let takeaway: String
}

struct ReasoningStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}
