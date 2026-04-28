//
//  ContentView.swift
//  AWSUploadTest
//
//  Created by Mac on 28/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var shouldRecord: Bool = false
    
    var body: some View {
        VStack{
            Button {
                shouldRecord.toggle()
            } label: {
                Image(systemName: "microphone")
                    .resizable()
                    .frame(width: 60, height: 90)
                    .foregroundStyle(shouldRecord ? .red : .mint)
                
            }
        }
        .onAppear {
            if shouldRecord{
                AudioManager.shared.startRecording()
            }else{
                AudioManager.shared.stopRecording()
            }
            
        }
    }
}

#Preview {
    ContentView()
}
