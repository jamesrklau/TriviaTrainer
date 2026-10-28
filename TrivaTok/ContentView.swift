
import SwiftUI

struct ContentView: View {
    @State private var questions: [TriviaQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var answerOptions: [String] = []

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var correctCount = 0
    @State private var hasFinished = false

    private let triviaService = TriviaService()

    private var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else {
            return nil
        }

        return questions[currentIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Fetching questions...")
                } else if let errorMessage {
                    errorView(errorMessage)
                } else if hasFinished {
                    resultsView
                } else if let question = currentQuestion {
                    quizView(question)
                } else {
                    ContentUnavailableView(
                        "Ready to play?",
                        systemImage: "brain.head.profile",
                        description: Text("Load your first trivia round.")
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Trivia Trainer")
            .task {
                if questions.isEmpty && !isLoading {
                    await loadQuestions()
                }
            }
        }
    }

    private func quizView(_ question: TriviaQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("QUESTION \(currentIndex + 1) OF \(questions.count)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                Text(question.difficulty.capitalized)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }

            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(max(questions.count, 1))
            )

            Text(question.category)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(question.question)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(answerOptions, id: \.self) { answer in
                    Button {
                        selectAnswer(answer, for: question)
                    } label: {
                        HStack {
                            Text(answer)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if selectedAnswer == answer {
                                Image(
                                    systemName: answer == question.correctAnswer
                                        ? "checkmark.circle.fill"
                                        : "xmark.circle.fill"
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(answerBackground(answer, question: question))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.gray.opacity(0.2))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedAnswer != nil)
                    .foregroundStyle(.primary)
                }
            }

            if selectedAnswer != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text(
                        selectedAnswer == question.correctAnswer
                            ? "Correct!"
                            : "Not quite!"
                    )
                    .font(.headline)
                    .foregroundStyle(
                        selectedAnswer == question.correctAnswer
                            ? .green : .red
                    )

                    Text("The answer is \(question.correctAnswer).")
                        .font(.subheadline)

                    Text(
                        "This question is from the \(question.category) category."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Button {
                        advanceQuestion()
                    } label: {
                        Text(
                            currentIndex == questions.count - 1
                                ? "See Results"
                                : "Next Question"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding(.top, 8)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func answerBackground(
        _ answer: String,
        question: TriviaQuestion
    ) -> Color {
        guard selectedAnswer != nil else {
            return Color.gray.opacity(0.08)
        }

        if answer == question.correctAnswer {
            return Color.green.opacity(0.15)
        }

        if answer == selectedAnswer {
            return Color.red.opacity(0.15)
        }

        return Color.gray.opacity(0.08)
    }

    private func selectAnswer(
        _ answer: String,
        for question: TriviaQuestion
    ) {
        guard selectedAnswer == nil else { return }

        selectedAnswer = answer

        if answer == question.correctAnswer {
            correctCount += 1
        }
    }

    private func advanceQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            answerOptions = questions[currentIndex].allAnswers.shuffled()
        } else {
            hasFinished = true
        }
    }

    private var resultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Round Complete!")
                .font(.largeTitle.bold())

            Text("\(correctCount) out of \(questions.count) correct")
                .font(.title2)

            Text(
                "Every question you miss is an opportunity to learn something new."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Button("Play Another Round") {
                Task {
                    await loadQuestions()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)

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
        }
        .padding()
    }

    @MainActor
    private func loadQuestions() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let fetchedQuestions = try await triviaService.fetchQuestions()

            questions = fetchedQuestions
            currentIndex = 0
            selectedAnswer = nil
            correctCount = 0
            hasFinished = false
            answerOptions = fetchedQuestions.first?.allAnswers.shuffled() ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
