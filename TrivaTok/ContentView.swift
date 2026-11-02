
import SwiftUI

struct ContentView: View {
    // MARK: - Screen and quiz state

    @State private var selectedDifficulty: TriviaDifficulty? = nil
    @State private var hasStartedQuiz = false
    @State private var isLoading = false
    @State private var hasFinished = false

    // MARK: - Question state

    @State private var questions: [TriviaQuestion] = []
    @State private var currentIndex = 0
    @State private var answerOptions: [String] = []
    @State private var selectedAnswer: String? = nil
    @State private var correctCount = 0
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading questions...")
                } else if let errorMessage {
                    errorView(message: errorMessage)
                } else if hasFinished {
                    resultsView
                } else if hasStartedQuiz && !questions.isEmpty {
                    quizView
                } else {
                    homeView
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("TriviaTrainer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Home screen

    private var homeView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("TriviaTrainer")
                .font(.largeTitle.bold())

            Text("Get curious. Make connections. Know more.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Text("Choose your difficulty")
                .font(.headline)

            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(TriviaDifficulty.allCases) { difficulty in
                    Text(difficulty.title)
                        .tag(Optional(difficulty))
                }
            }
            .pickerStyle(.segmented)

            Text(difficultyDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Task {
                    await loadQuestions()
                }
            } label: {
                Label("Start Quiz", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedDifficulty == nil)

            Spacer()
        }
    }

    private var difficultyDescription: String {
        switch selectedDifficulty {
        case .easy:
            return "Easy: warm up with more accessible questions."
        case .medium:
            return "Medium: challenge what you already know."
        case .hard:
            return "Hard: put your knowledge to the test."
        case nil:
            return "Choose a difficulty to get started."
        }
    }

    // MARK: - Quiz screen

    private var quizView: some View {
        let question = questions[currentIndex]

        return VStack(spacing: 20) {
            HStack {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(selectedDifficulty?.title ?? "")
                    .font(.subheadline.bold())
            }

            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(questions.count)
            )

            Text(question.category)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(question.question)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            ForEach(answerOptions, id: \.self) { answer in
                Button {
                    selectedAnswer = answer
                } label: {
                    HStack {
                        Text(answer)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if selectedAnswer != nil &&
                            answer == questions[currentIndex].correctAnswer {
                            Image(systemName: "checkmark.circle.fill")
                        } else if selectedAnswer == answer {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(answerBackground(for: answer))
                    .foregroundStyle(answerForeground(for: answer))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(answerBorder(for: answer), lineWidth: 1)
                }
                .disabled(selectedAnswer != nil)
            }

            if let selectedAnswer {
                if selectedAnswer == question.correctAnswer {
                    Label("Correct!", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Text("The correct answer is: \(question.correctAnswer)")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            Button {
                advanceQuestion()
            } label: {
                Text(
                    currentIndex == questions.count - 1
                    ? "See Results"
                    : "Next Question"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedAnswer == nil)
        }
    }
    
    private func answerBackground(for answer: String) -> Color {
        guard let selectedAnswer else {
            return Color(.secondarySystemBackground)
        }

        if answer == questions[currentIndex].correctAnswer {
            return .green.opacity(0.2)
        }

        if answer == selectedAnswer {
            return .red.opacity(0.2)
        }

        return Color(.secondarySystemBackground)
    }

    private func answerForeground(for answer: String) -> Color {
        guard selectedAnswer != nil else {
            return .primary
        }

        if answer == questions[currentIndex].correctAnswer {
            return .green
        }

        if answer == selectedAnswer {
            return .red
        }

        return .primary
    }

    private func answerBorder(for answer: String) -> Color {
        guard selectedAnswer != nil else {
            return Color(.separator)
        }

        if answer == questions[currentIndex].correctAnswer {
            return .green
        }

        if answer == selectedAnswer {
            return .red
        }

        return Color(.separator)
    }

    // MARK: - Results screen

    private var resultsView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: resultsIcon)
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text(resultsHeadline)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("\(correctCount) out of \(questions.count) correct")
                .font(.title2)

            Text("\(scorePercentage)%")
                .font(.system(size: 44, weight: .bold))

            Text("Difficulty: \(selectedDifficulty?.title ?? "Unknown")")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(resultsMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Every round is a chance to learn something new.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                Task {
                    await loadQuestions()
                }
            } label: {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)

            Button("Change Difficulty") {
                returnHome()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }

    private var scorePercentage: Int {
        guard !questions.isEmpty else { return 0 }
        return correctCount * 100 / questions.count
    }

    private var resultsIcon: String {
        if correctCount >= 4 {
            return "trophy.fill"
        } else if correctCount == 3 {
            return "star.fill"
        } else {
            return "book.fill"
        }
    }

    private var resultsHeadline: String {
        switch correctCount {
        case 5:
            return "Perfect Round!"
        case 4:
            return "Great Work!"
        case 3:
            return "Solid Effort!"
        default:
            return "Keep Learning!"
        }
    }

    private var resultsMessage: String {
        guard let difficulty = selectedDifficulty else {
            return "Keep practicing and building your knowledge."
        }

        switch correctCount {
        case 5:
            if difficulty == .hard {
                return "Outstanding! You answered every question correctly on Hard difficulty."
            }
            return "Amazing! You got every question right. Ready for another challenge?"

        case 4:
            if difficulty == .hard {
                return "Excellent result on a challenging round. Keep sharpening your trivia knowledge."
            }
            return "You were very close to a perfect round. Keep that momentum going!"

        case 3:
            if difficulty == .hard {
                return "Three correct on Hard is a good learning opportunity. Review what surprised you and try again."
            }
            return "You're building your knowledge. A few more connections could help you improve."

        default:
            if difficulty == .easy {
                return "Use this round to find gaps in your knowledge. Start with the explanations as we add them to the app."
            }
            return "These were challenging questions. Every missed answer is an opportunity to learn something memorable."
        }
    }

    // MARK: - Loading and errors

    @MainActor
    private func loadQuestions() async {
        guard let difficulty = selectedDifficulty else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let service = TriviaService()

            let fetchedQuestions = try await service.fetchQuestions(
                amount: 5,
                difficulty: difficulty
            )

            guard !fetchedQuestions.isEmpty else {
                errorMessage = "No questions were returned. Please try again."
                hasStartedQuiz = true
                return
            }

            questions = fetchedQuestions
            currentIndex = 0
            correctCount = 0
            selectedAnswer = nil
            answerOptions = fetchedQuestions[0].allAnswers
            hasFinished = false
            hasStartedQuiz = true

            print("Selected difficulty: \(difficulty.rawValue)")
            print("Returned difficulties: \(fetchedQuestions.map(\.difficulty))")

        } catch {
            errorMessage = error.localizedDescription
            hasStartedQuiz = true
        }
    }

    // MARK: - Quiz actions

    private func advanceQuestion() {
        guard let answer = selectedAnswer else { return }

        if answer == questions[currentIndex].correctAnswer {
            correctCount += 1
        }

        if currentIndex == questions.count - 1 {
            hasFinished = true
        } else {
            currentIndex += 1
            selectedAnswer = nil
            answerOptions = questions[currentIndex].allAnswers
        }
    }

    private func returnHome() {
        hasStartedQuiz = false
        hasFinished = false
        errorMessage = nil
        questions = []
        answerOptions = []
        selectedAnswer = nil
        currentIndex = 0
        correctCount = 0
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Couldn't Load Questions")
                .font(.title2.bold())

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Try Again") {
                Task {
                    await loadQuestions()
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Return Home") {
                returnHome()
            }
            .buttonStyle(.bordered)
        }
    }
}
