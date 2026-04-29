//
//  ContentView.swift
//  AWSUploadTest
//
//  Created by Mac on 28/04/26.
//

import SwiftUI

struct RecordingScreenView: View {
    
    @StateObject private var speechManager = SpeechManager.shared
    
    @State private var currentStep: Int = 1
    @State private var records: [SentenceRecord] = []
    @State private var showCreateButton: Bool = false
    
    @State private var navigateToPreview = false
    @State private var createdFileURL: URL?
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 30) {
                
                // Instruction
                if currentStep == 1 && records.isEmpty {
                    Text("You will record 3 sentences.\nTap Start and speak clearly.")
                        .multilineTextAlignment(.center)
                }
                
                // Step title
                if currentStep <= 3 {
                    Text("Speak your \(ordinal(currentStep)) sentence")
                        .font(.title2)
                }
                
                // Mic Button
                Button {
                    Task {
                        if speechManager.isRecording {
                            stopAndSave()
                        } else {
                            await speechManager.startRecording()
                        }
                    }
                } label: {
                    Image(systemName: "mic.fill")
                        .resizable()
                        .frame(width: 60, height: 80)
                        .foregroundStyle(speechManager.isRecording ? .red : .blue)
                }
                
                // Live transcript (optional but useful)
                Text(speechManager.transcript)
                    .padding()
                
                // Show recorded sentences
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(records) { record in
                        Text("\(record.sentenceNumber). \(record.sentenceSpoken)")
                    }
                }
                
                // Create JSON Button
                if showCreateButton {
                    Button("Create JSON") {
                        createJSONFile()
                    }
                    .padding()
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToPreview) {
                if let url = createdFileURL {
                    JSONPreviewView(fileURL: url)
                }
            }
        }
    }
}

extension RecordingScreenView {
    
    func stopAndSave() {
        speechManager.stopRecording()
        
        let text = speechManager.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty else { return }
        
        let record = SentenceRecord(
            id: UUID().uuidString,
            sentenceNumber: currentStep,
            sentenceSpoken: text,
            createdAt: Date()
        )
        
        records.append(record)
        
        // Reset transcript for next input
        speechManager.transcript = ""
        
        if currentStep < 3 {
            currentStep += 1
        } else {
            showCreateButton = true
        }
    }
    
    func ordinal(_ number: Int) -> String {
        switch number {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(number)th"
        }
    }
}

extension RecordingScreenView {
    
    func createJSONFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(records)
            
            let fileName = "Audio-\(formattedDate()).json"
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)
            
            try data.write(to: url)
            
            print("SON saved at:", url)
            
            // store + navigate
            createdFileURL = url
            navigateToPreview = true
            
        } catch {
            print("Failed to create JSON:", error)
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.string(from: Date())
    }
}


#Preview {
    RecordingScreenView()
}


