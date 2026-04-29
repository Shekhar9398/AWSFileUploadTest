//
//  AudioManager.swift
//  AWSUploadTest
//

import AVFoundation
import Combine
import Speech

// MARK: - Live mic capture + on-device speech-to-text
@MainActor
final class SpeechManager: ObservableObject {

    // MARK: - Singleton (one mic session for the whole app)
    static let shared = SpeechManager()
    private init() {}

    // MARK: - Published state observed by the UI
    @Published var transcript: String = ""
    @Published private(set) var isRecording: Bool = false

    // MARK: - Audio + Speech engines
    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer()

    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    // MARK: - Public API
    func startRecording() async {
        guard !isRecording else { return }

        guard await hasPermissions() else {
            print("SpeechManager: permissions denied")
            return
        }

        do {
            try configureAudioSession()
            try beginRecognition()
            isRecording = true
        } catch {
            print("SpeechManager: failed to start —", error.localizedDescription)
            stopRecording()
        }
    }

    func stopRecording() {
        guard isRecording || audioEngine.isRunning else {
            isRecording = false
            return
        }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        request?.endAudio()
        task?.cancel()

        request = nil
        task = nil
        isRecording = false
    }

    func resetTranscript() {
        transcript = ""
    }
}

// MARK: - Audio session + recognition setup
private extension SpeechManager {

    // MARK: - Configure the shared audio session for recording
    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Wire up the speech recognition pipeline
    func beginRecognition() throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result { self.transcript = result.bestTranscription.formattedString }
            if error != nil { self.stopRecording() }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }
}

// MARK: - Permission helpers
private extension SpeechManager {

    // MARK: - Ask both mic + speech permissions in parallel
    func hasPermissions() async -> Bool {
        async let mic = askMic()
        async let speech = askSpeech()
        let (gotMic, gotSpeech) = await (mic, speech)
        return gotMic && gotSpeech
    }

    func askMic() async -> Bool {
        await withCheckedContinuation { cont in
            AVAudioApplication.requestRecordPermission { cont.resume(returning: $0) }
        }
    }

    func askSpeech() async -> Bool {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { cont.resume(returning: $0 == .authorized) }
        }
    }
}
