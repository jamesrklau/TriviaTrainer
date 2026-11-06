
import Foundation
import CryptoKit

struct TriviaQuestion: Identifiable {

    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    // A stable identity derived from the question itself.
    var id: String {
        Self.makeFingerprint(
            category: category,
            question: question,
            correctAnswer: correctAnswer
        )
    }

    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }

    private static func makeFingerprint(
        category: String,
        question: String,
        correctAnswer: String
    ) -> String {

        let normalizedCategory = normalize(category)
        let normalizedQuestion = normalize(question)
        let normalizedAnswer = normalize(correctAnswer)

        let fingerprintInput = [
            normalizedCategory,
            normalizedQuestion,
            normalizedAnswer
        ].joined(separator: "|")

        let hash = SHA256.hash(
            data: Data(fingerprintInput.utf8)
        )

        return hash.map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func normalize(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en_US_POSIX")
            )
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
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
