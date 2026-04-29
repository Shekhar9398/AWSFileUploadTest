//
//  Theme.swift
//  AWSUploadTest
//

import SwiftUI

// MARK: - Reusable design tokens (colors, gradients, radii)
enum Theme {

    // MARK: - Brand colors
    static let primary = Color(red: 0.36, green: 0.40, blue: 0.96)
    static let secondary = Color(red: 0.62, green: 0.36, blue: 0.96)
    static let danger = Color(red: 0.96, green: 0.34, blue: 0.40)
    static let success = Color(red: 0.20, green: 0.76, blue: 0.50)

    // MARK: - Background gradient used app-wide
    static let background = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.97, blue: 1.00),
            Color(red: 0.92, green: 0.94, blue: 1.00)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Brand gradient for primary CTAs and accents
    static let brand = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Standard corner radius
    static let radius: CGFloat = 18
}
