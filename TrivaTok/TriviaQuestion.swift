import Foundation

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
}

// This matches the JSON structure returned by Open Trivia DB.
struct TriviaResponse: Decodable {
    let response_code: Int
    let results: [TriviaAPIQuestion]
}

struct TriviaAPIQuestion: Decodable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
