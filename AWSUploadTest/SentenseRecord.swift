//
//  SentenseRecord.swift
//  AWSUploadTest
//
//  Created by Mac on 29/04/26.
//

import Foundation

struct SentenceRecord: Codable, Identifiable {
    let id: String
    let sentenceNumber: Int
    let sentenceSpoken: String
    let createdAt: Date
}
