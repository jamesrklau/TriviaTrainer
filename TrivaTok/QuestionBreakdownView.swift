//
//  QuestionBreakdownView.swift
//  TrivaTok
//
//  Created by Jaime Klau on 11/1/26.
//

import SwiftUI

struct QuestionBreakdownView: View {
    let explanation: QuestionExplanation

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Section 1: Explain the answer
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

            // Section 2: Break down the reasoning
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
                            .background(
                                Color.blue,
                                in: Circle()
                            )

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

            Divider()

            // Section 3: A memorable takeaway
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
