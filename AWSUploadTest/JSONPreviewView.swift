//
//  JSONPreviewView.swift
//  AWSUploadTest
//

import SwiftUI

// MARK: - Pretty-prints the saved JSON file with copy + share actions
struct JSONPreviewView: View {

    let fileURL: URL

    @State private var jsonText: String = ""
    @State private var isLoading: Bool = true
    @State private var didCopy: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                content
                    .padding(20)
            }
        }
        .navigationTitle("JSON Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .task { await loadJSON() }
    }
}

// MARK: - Content states
private extension JSONPreviewView {

    @ViewBuilder
    var content: some View {
        if isLoading {
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, minHeight: 200)
        } else {
            jsonCard
        }
    }

    // MARK: - The card holding the formatted JSON text
    var jsonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(fileURL.lastPathComponent)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            Text(jsonText)
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.radius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Toolbar (copy + share)
private extension JSONPreviewView {

    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                Button(action: copyToClipboard) {
                    Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                }
                .disabled(jsonText.isEmpty)

                ShareLink(item: fileURL) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// MARK: - Loading + actions
private extension JSONPreviewView {

    // MARK: - Read + pretty-print the file off the main thread
    func loadJSON() async {
        let url = fileURL
        let pretty = await Task.detached(priority: .userInitiated) {
            prettyPrint(url: url)
        }.value

        jsonText = pretty
        isLoading = false
    }

    // MARK: - Copy current JSON to the system clipboard
    func copyToClipboard() {
        UIPasteboard.general.string = jsonText
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            didCopy = false
        }
    }
}

// MARK: - Pure helper (pretty-print a JSON file's contents)
private func prettyPrint(url: URL) -> String {
    guard let data = try? Data(contentsOf: url) else {
        return "Unable to read file"
    }

    if let object = try? JSONSerialization.jsonObject(with: data),
       let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
       let string = String(data: pretty, encoding: .utf8) {
        return string
    }

    return String(data: data, encoding: .utf8) ?? "Unsupported encoding"
}
