//
//  SpeechManager.swift
//  AWSUploadTest
//
//  Created by Mac on 29/04/26.
//
import Combine
import AVFoundation
import Speech

@MainActor
final class SpeechManager: ObservableObject {
        
    // MARK: - Singleton
    static let shared = SpeechManager()
    private init() {}
    
    // MARK: - Published State
    @Published var transcript: String = ""
    @Published private(set) var spokenWords: [String] = []
    @Published private(set) var isRecording: Bool = false
    
    // MARK: - Private Properties
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - Public API
    
    func startRecording() async {
        guard !isRecording else { return }
        
        let hasPermission = await requestPermissions()
        guard hasPermission else {
            print("Permissions not granted")
            return
        }
        
        do {
            try startAudioSession()
            try startRecognition()
            isRecording = true
        } catch {
            print("Failed to start recording:", error)
            stopRecording()
        }
        
        print("SpeechManger: Recording is started")
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionTask = nil
        recognitionRequest = nil
        
        isRecording = false
        
        print("SpeechManager: Recording is stopped")
    }
}

// MARK: - Setup
private extension SpeechManager {
    
    func startAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func startRecognition() throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechManager", code: -1)
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        recognitionTask = speechRecognizer?.recognitionTask(
            with: recognitionRequest,
            resultHandler: { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    self.handleRecognition(result: result)
                }
                
                if error != nil {
                    self.stopRecording()
                }
            }
        )
        
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}

// MARK: - Processing
private extension SpeechManager {
    func handleRecognition(result: SFSpeechRecognitionResult) {
        let text = result.bestTranscription.formattedString
        
        transcript = text
        
        spokenWords = text
            .split(whereSeparator: { $0.isWhitespace })
            .map { String($0) }
        print("SpeechManager: Spoken words are : \(spokenWords)")
    }
}

// MARK: - Permissions
private extension SpeechManager {
    
    func requestPermissions() async -> Bool {
        let mic = await requestMicrophonePermission()
        let speech = await requestSpeechPermission()
        
        return mic && speech
    }
    
    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission() { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
