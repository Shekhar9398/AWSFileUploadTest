//
//  MicButton.swift
//  AWSUploadTest
//

import SwiftUI

// MARK: - Big tap-to-record button with a pulsing ring while recording
struct MicButton: View {

    let isRecording: Bool
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            ZStack {
                pulseRing
                solidCircle
                icon
            }
            .frame(width: 140, height: 140)
        }
        .buttonStyle(.plain)
        .onAppear { pulse = true }
        .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
    }
}

// MARK: - Subviews
private extension MicButton {

    // MARK: - Animated outer ring shown only while recording
    var pulseRing: some View {
        Circle()
            .stroke(Theme.danger.opacity(0.35), lineWidth: 6)
            .scaleEffect(pulse && isRecording ? 1.25 : 1.0)
            .opacity(isRecording ? (pulse ? 0 : 1) : 0)
            .animation(
                .easeOut(duration: 1.2).repeatForever(autoreverses: false),
                value: pulse
            )
    }

    // MARK: - The solid filled circle behind the icon
    var solidCircle: some View {
        Circle()
            .fill(isRecording ? AnyShapeStyle(Theme.danger) : AnyShapeStyle(Theme.brand))
            .shadow(color: (isRecording ? Theme.danger : Theme.primary).opacity(0.45),
                    radius: 18, x: 0, y: 10)
    }

    // MARK: - Mic / stop glyph
    var icon: some View {
        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.white)
    }
}

#Preview {
    VStack(spacing: 40) {
        MicButton(isRecording: false) {}
        MicButton(isRecording: true) {}
    }
    .padding()
}
