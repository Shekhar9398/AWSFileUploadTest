//
//  JSONPreviewView.swift
//  AWSUploadTest
//
//  Created by Mac on 29/04/26.
//

import SwiftUI

struct JSONPreviewView: View {
    
    let fileURL: URL
    @State private var jsonText: String = "Loading..."
    
    var body: some View {
        ScrollView {
            Text(jsonText)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .navigationTitle("JSON Preview")
        .onAppear {
            loadJSON()
        }
    }
}

extension JSONPreviewView {
    
    func loadJSON() {
        do {
            let data = try Data(contentsOf: fileURL)
            
            if let formatted = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: formatted, options: .prettyPrinted),
               let string = String(data: prettyData, encoding: .utf8) {
                
                jsonText = string
            } else {
                jsonText = String(data: data, encoding: .utf8) ?? "Unable to read file"
            }
            
        } catch {
            jsonText = "Error loading JSON: \(error.localizedDescription)"
        }
    }
}
