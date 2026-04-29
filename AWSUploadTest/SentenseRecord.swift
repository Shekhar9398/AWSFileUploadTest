//
//  SentenseRecord.swift
//  AWSUploadTest
//

import Foundation

// MARK: - One spoken sentence captured from the user
struct SentenceRecord: Codable, Identifiable, Hashable {
    let id: String
    let sentenceNumber: Int
    let sentenceSpoken: String
    let createdAt: Date

    // MARK: - Convenience initialiser used by the recorder
    init(number: Int, text: String) {
        self.id = UUID().uuidString
        self.sentenceNumber = number
        self.sentenceSpoken = text
        self.createdAt = Date()
    }
}
