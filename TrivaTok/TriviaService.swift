import Foundation

enum TriviaServiceError: LocalizedError {
    case invalidResponse
    case apiError(Int)
    case noQuestions

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .apiError(let code):
            return "The trivia API returned error code \(code)."
        case .noQuestions:
            return "No questions were returned. Please try again."
        }
    }
}

struct TriviaService {
    private let baseURL = "https://opentdb.com/api.php"

    func fetchQuestions(amount: Int = 5) async throws -> [TriviaQuestion] {
        var components = URLComponents(string: baseURL)!

        components.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "type", value: "multiple"),
            URLQueryItem(name: "encode", value: "base64")
        ]

        guard let url = components.url else {
            throw TriviaServiceError.invalidResponse
        }

        // 1. Make the network request.
        let (data, response) = try await URLSession.shared.data(from: url)

        // 2. Check the HTTP response.
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TriviaServiceError.invalidResponse
        }

        // 3. Convert the JSON response into Swift types.
        let decodedResponse = try JSONDecoder().decode(
            TriviaResponse.self,
            from: data
        )

        guard decodedResponse.response_code == 0 else {
            throw TriviaServiceError.apiError(
                decodedResponse.response_code
            )
        }

        guard !decodedResponse.results.isEmpty else {
            throw TriviaServiceError.noQuestions
        }

        // 4. Convert API questions into app questions.
        return try decodedResponse.results.map { item in
            TriviaQuestion(
                category: try decodeBase64(item.category),
                difficulty: try decodeBase64(item.difficulty),
                question: try decodeBase64(item.question),
                correctAnswer: try decodeBase64(item.correct_answer),
                incorrectAnswers: try item.incorrect_answers.map {
                    try decodeBase64($0)
                }
            )
        }
    }

    private func decodeBase64(_ value: String) throws -> String {
        guard let data = Data(base64Encoded: value),
              let decoded = String(data: data, encoding: .utf8) else {
            throw TriviaServiceError.invalidResponse
        }

        return decoded
    }
}
