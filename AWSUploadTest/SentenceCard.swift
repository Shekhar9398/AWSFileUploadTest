//
//  SentenceCard.swift
//  AWSUploadTest
//

import SwiftUI

// MARK: - Card that shows a single recorded sentence with its number
struct SentenceCard: View {

    let record: SentenceRecord

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            numberBadge
            Text(record.sentenceSpoken)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.success)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.radius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Subviews
private extension SentenceCard {

    // MARK: - Circular number tag on the left of the card
    var numberBadge: some View {
        Text("\(record.sentenceNumber)")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(Theme.brand, in: Circle())
    }
}

#Preview {
    SentenceCard(record: SentenceRecord(number: 1, text: "The quick brown fox jumps over the lazy dog."))
        .padding()
        .background(Theme.background)
}
