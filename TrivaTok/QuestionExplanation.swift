
import Foundation

struct QuestionExplanation: Codable {

    let explanation: String
    let reasoningSteps: [ReasoningStep]
    let relatedFacts: [RelatedFact]
    let takeaway: String

    let source: ExplanationSource
    let reviewStatus: ExplanationReviewStatus
}

struct ReasoningStep: Identifiable, Codable {

    var id = UUID()
    let title: String
    let detail: String
}

struct RelatedFact: Identifiable, Codable {

    var id = UUID()
    let title: String
    let detail: String
}

enum ExplanationSource: String, Codable {
    case curated
    case aiGenerated
}

enum ExplanationReviewStatus: String, Codable {
    case reviewed
    case needsReview
}
