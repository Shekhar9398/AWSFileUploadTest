//
//  PrimaryButton.swift
//  AWSUploadTest
//

import SwiftUI

// MARK: - Reusable full-width gradient call-to-action button
struct PrimaryButton: View {

    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.brand, in: RoundedRectangle(cornerRadius: Theme.radius))
            .foregroundStyle(.white)
            .shadow(color: Theme.primary.opacity(0.35), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step indicator (3 dots showing recording progress)
struct StepDots: View {

    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? AnyShapeStyle(Theme.brand) : AnyShapeStyle(Color.gray.opacity(0.25)))
                    .frame(width: step == current ? 28 : 10, height: 10)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: current)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        StepDots(total: 3, current: 2)
        PrimaryButton("Create JSON", systemImage: "doc.badge.plus") {}
    }
    .padding()
    .background(Theme.background)
}
