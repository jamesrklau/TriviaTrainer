
import Foundation

enum ExplanationLibrary {

    static let marsAndRomanMythology = QuestionExplanation(

        explanation: """
        Mars is named after the Roman god of war. The planet's reddish \
        appearance has historically been associated with blood and warfare.
        """,

        reasoningSteps: [
            ReasoningStep(
                title: "Identify the subject",
                detail: """
                The question asks about a planet, so we're looking \
                for an astronomical object.
                """
            ),

            ReasoningStep(
                title: "Find the key clue",
                detail: """
                The phrase "Roman god of war" points us toward \
                Roman mythology.
                """
            ),

            ReasoningStep(
                title: "Connect the concepts",
                detail: """
                Mars is the Roman god of war. His name is also used \
                for the planet.
                """
            ),

            ReasoningStep(
                title: "Confirm the answer",
                detail: """
                Mars matches both clues: it is a planet, and its \
                name comes from the Roman god of war.
                """
            )
        ],

        relatedFacts: [
            RelatedFact(
                title: "Mars has two moons",
                detail: """
                Mars has two small moons called Phobos and Deimos. \
                Their names come from Greek mythology and mean fear \
                and terror.
                """
            ),

            RelatedFact(
                title: "The Red Planet",
                detail: """
                Mars appears reddish because iron minerals in its \
                surface have oxidized, creating rust-like material.
                """
            )
        ],

        takeaway: """
        When trivia questions mention mythology, look for connections \
        to astronomy, history, literature, and familiar names.
        """,

        source: .curated,
        reviewStatus: .reviewed
    )

    static func explanation(
        for question: TriviaQuestion
    ) -> QuestionExplanation? {

        let questionText = question.question.lowercased()
        let correctAnswer = question.correctAnswer.lowercased()

        if correctAnswer == "mars" &&
            questionText.contains("roman god of war") {

            return marsAndRomanMythology
        }

        return nil
    }
}
