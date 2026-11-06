
import SwiftUI

struct QuestionBreakdownView: View {

    let explanation: QuestionExplanation

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            // Why This Answer?
            VStack(alignment: .leading, spacing: 8) {

                Label(
                    "Why This Answer?",
                    systemImage: "lightbulb.fill"
                )
                .font(.headline)
                .foregroundStyle(.blue)

                Text(explanation.explanation)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            // Break It Down
            VStack(alignment: .leading, spacing: 14) {

                Label(
                    "Break It Down",
                    systemImage: "brain.head.profile"
                )
                .font(.headline)
                .foregroundStyle(.blue)

                ForEach(
                    Array(explanation.reasoningSteps.enumerated()),
                    id: \.element.id
                ) { index, step in

                    HStack(alignment: .top, spacing: 12) {

                        Text("\(index + 1)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue, in: Circle())

                        VStack(alignment: .leading, spacing: 4) {

                            Text(step.title)
                                .font(.subheadline.bold())

                            Text(step.detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                    }
                }
            }

            // Explore Further
            if !explanation.relatedFacts.isEmpty {

                Divider()

                VStack(alignment: .leading, spacing: 12) {

                    Label(
                        "Explore Further",
                        systemImage: "sparkles"
                    )
                    .font(.headline)
                    .foregroundStyle(.blue)

                    ForEach(explanation.relatedFacts) { fact in

                        VStack(alignment: .leading, spacing: 4) {

                            Text(fact.title)
                                .font(.subheadline.bold())

                            Text(fact.detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                    }
                }
            }

            Divider()

            // Remember This
            VStack(alignment: .leading, spacing: 8) {

                Label(
                    "Remember This",
                    systemImage: "bookmark.fill"
                )
                .font(.headline)
                .foregroundStyle(.blue)

                Text(explanation.takeaway)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

#Preview {
    ScrollView {
        QuestionBreakdownView(
            explanation: ExplanationLibrary.marsAndRomanMythology
        )
        .padding()
    }
}
