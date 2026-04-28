//
//  AudioManager.swift
//  AWSUploadTest
//
//  Created by Mac on 28/04/26.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private init(){}
    
    ///MARK:- Dependencies
    private var recorder: AVAudioRecorder?
    
    ///MARK:- Start Recording
    func startRecording() {
        print("Recording is started")
        
        Task {
            let granted = await requestMicrophonePermission()
            
            guard granted else {
                print("Microphone permission is not granted")
                return
            }
            setupAndStartRecording()
        }
    }
    
    ///MARK:- Stop Audio Recording
    func stopRecording() {
        recorder?.stop()
        recorder = nil
        print("Recording is stopped")
    }
    
    ///MARK:- setup Audio Session and Recorder
    private func setupAndStartRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("recording.wav")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
            ]
            
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.prepareToRecord()
            recorder?.record()
        } catch {
            print("Error while setting up recorder:", error)
        }
    }
    
    ///MARK:- Request Microphone Permission
    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
}
