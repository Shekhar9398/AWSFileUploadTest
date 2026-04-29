//
//  RecordingScreenView.swift
//  AWSUploadTest
//

import SwiftUI

// MARK: - Main flow: record 3 sentences, then export them as JSON
struct RecordingScreenView: View {

    // MARK: - Constants
    private let totalSentences = 3

    // MARK: - State
    @StateObject private var speech = SpeechManager.shared
    @State private var sentences: [SentenceRecord] = []
    @State private var savedFile: URL?

    // MARK: - Derived state
    private var currentStep: Int { min(sentences.count + 1, totalSentences) }
    private var isFinished: Bool { sentences.count == totalSentences }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    header
                    transcriptCard
                    Spacer(minLength: 0)
                    MicButton(isRecording: speech.isRecording, action: toggleRecording)
                        .disabled(isFinished)
                        .opacity(isFinished ? 0.4 : 1)
                    Spacer(minLength: 0)
                    recordedList
                    if isFinished {
                        PrimaryButton("Create JSON", systemImage: "doc.badge.plus", action: exportJSON)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationDestination(item: $savedFile) { url in
                JSONPreviewView(fileURL: url)
            }
        }
    }
}

// MARK: - Header (title, subtitle, progress dots)
private extension RecordingScreenView {

    var header: some View {
        VStack(spacing: 10) {
            Text(isFinished ? "All set!" : "Sentence \(currentStep) of \(totalSentences)")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text(isFinished
                 ? "Tap below to save your sentences as JSON."
                 : "Tap the mic and speak clearly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            StepDots(total: totalSentences, current: currentStep)
                .padding(.top, 4)
        }
        .padding(.top, 8)
    }
}

// MARK: - Live transcript bubble
private extension RecordingScreenView {

    var transcriptCard: some View {
        Text(speech.transcript.isEmpty ? "Your speech will appear here…" : speech.transcript)
            .font(.body)
            .foregroundStyle(speech.transcript.isEmpty ? .secondary : .primary)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .padding(16)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: Theme.radius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius)
                    .stroke(speech.isRecording ? Theme.danger : Color.black.opacity(0.06),
                            lineWidth: speech.isRecording ? 2 : 1)
            )
            .animation(.easeInOut(duration: 0.2), value: speech.isRecording)
    }
}

// MARK: - List of saved sentences (cards)
private extension RecordingScreenView {

    var recordedList: some View {
        VStack(spacing: 10) {
            ForEach(sentences) { record in
                SentenceCard(record: record)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sentences)
    }
}

// MARK: - Actions
private extension RecordingScreenView {

    // MARK: - Toggle the mic — start, or stop and save the spoken sentence
    func toggleRecording() {
        if speech.isRecording {
            stopAndSaveSentence()
        } else {
            Task { await speech.startRecording() }
        }
    }

    // MARK: - Stop the mic and store the trimmed transcript as a record
    func stopAndSaveSentence() {
        speech.stopRecording()
        let text = speech.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        sentences.append(SentenceRecord(number: sentences.count + 1, text: text))
        speech.resetTranscript()
    }

    // MARK: - Encode all sentences to JSON and write to the documents folder
    func exportJSON() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(sentences)
            let url = documentsURL().appendingPathComponent(makeFileName())
            try data.write(to: url, options: .atomic)
            savedFile = url
            print("JSON saved at:", url.path)
        } catch {
            print("Failed to write JSON:", error.localizedDescription)
        }
    }

    // MARK: - Build a filesystem-safe file name like "Audio-2026-04-29_14-32.json"
    func makeFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "Audio-\(formatter.string(from: Date())).json"
    }

    func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

#Preview {
    RecordingScreenView()
}
