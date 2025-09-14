//
//  ClipboardBufferViewModel.swift
//  MewNotch
//
//  Created by Assistant on 14/09/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum ClipboardContentType {
    case image, text, file
}

protocol ClipboardContent: Identifiable {
    var id: UUID { get }
    var timestamp: Date { get }
    var type: ClipboardContentType { get }
}

struct BufferedImage: ClipboardContent, Transferable {
    let id = UUID()
    let image: NSImage
    let timestamp: Date = Date()
    let type: ClipboardContentType = .image

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            guard let tiffData = item.image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                throw TransferError.exportFailed
            }
            return pngData
        }
    }

    enum TransferError: Error {
        case exportFailed
    }
}

struct BufferedText: ClipboardContent, Transferable {
    let id = UUID()
    let text: String
    let timestamp: Date = Date()
    let type: ClipboardContentType = .text

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .utf8PlainText) { item in
            item.text.data(using: .utf8) ?? Data()
        }
    }
}

struct BufferedFile: ClipboardContent, Transferable {
    let id = UUID()
    let url: URL
    let name: String
    let timestamp: Date = Date()
    let type: ClipboardContentType = .file

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .fileURL) { item in
            SentTransferredFile(item.url)
        }
    }
}

class ClipboardBufferViewModel: ObservableObject {
    @Published var content: [any ClipboardContent] = []

    private let maxItems = 3
    private var lastChangeCount: Int = 0
    private var timer: Timer?

    init() {
        checkClipboard()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Only check clipboard when screen is not locked
            if !NotchManager.shared.isScreenLocked {
                self.checkClipboard()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func checkClipboard() {
        let pasteboard = NSPasteboard.general

        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        // Check for images first
        if let imageData = pasteboard.data(forType: .tiff),
           let image = NSImage(data: imageData) {
            addContent(BufferedImage(image: image))
        } else if let imageData = pasteboard.data(forType: .png),
                  let image = NSImage(data: imageData) {
            addContent(BufferedImage(image: image))
        }
        // Check for text
        else if let text = pasteboard.string(forType: .string) {
            addContent(BufferedText(text: text))
        }
        // Check for files
        else if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
                let fileURL = fileURLs.first {
            let fileName = fileURL.lastPathComponent
            addContent(BufferedFile(url: fileURL, name: fileName))
        }
    }

    func addContent(_ newContent: any ClipboardContent) {
        content.insert(newContent, at: 0)

        if content.count > maxItems {
            content = Array(content.prefix(maxItems))
        }
    }

    func handleDrop(providers: [NSItemProvider], at index: Int) {
        for provider in providers {
            // Priority: Images first, then files, then text
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                    guard let data = data,
                          let image = NSImage(data: data) else { return }

                    DispatchQueue.main.async {
                        self.addContent(BufferedImage(image: image))
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    guard let url = item as? URL else { return }

                    // Check if it's an image file
                    if let image = NSImage(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.addContent(BufferedImage(image: image))
                        }
                    } else {
                        // It's a regular file
                        let fileName = url.lastPathComponent
                        DispatchQueue.main.async {
                            self.addContent(BufferedFile(url: url, name: fileName))
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        // If it's a file URL, treat as file
                        if url.isFileURL {
                            if let image = NSImage(contentsOf: url) {
                                DispatchQueue.main.async {
                                    self.addContent(BufferedImage(image: image))
                                }
                            } else {
                                let fileName = url.lastPathComponent
                                DispatchQueue.main.async {
                                    self.addContent(BufferedFile(url: url, name: fileName))
                                }
                            }
                        } else {
                            // Web URL - treat as text
                            DispatchQueue.main.async {
                                self.addContent(BufferedText(text: url.absoluteString))
                            }
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) ||
                      provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) ||
                      provider.hasItemConformingToTypeIdentifier(UTType.utf8PlainText.identifier) {
                // Handle all text types - try different identifiers
                let textTypes = [UTType.utf8PlainText.identifier, UTType.plainText.identifier, UTType.text.identifier]

                for textType in textTypes {
                    if provider.hasItemConformingToTypeIdentifier(textType) {
                        provider.loadItem(forTypeIdentifier: textType, options: nil) { item, error in
                            if let text = item as? String {
                                DispatchQueue.main.async {
                                    self.addContent(BufferedText(text: text))
                                }
                            }
                        }
                        break // Found a working type, stop trying others
                    }
                }
            }
        }
    }

    func removeContent(at index: Int) {
        guard index < content.count else { return }
        content.remove(at: index)
    }

    func openContent(at index: Int) {
        guard index < content.count else { return }

        let item = content[index]

        switch item.type {
        case .image:
            if let bufferedImage = item as? BufferedImage {
                openImage(bufferedImage)
            }
        case .text:
            if let bufferedText = item as? BufferedText {
                openText(bufferedText)
            }
        case .file:
            if let bufferedFile = item as? BufferedFile {
                openFile(bufferedFile)
            }
        }
    }

    private func openImage(_ bufferedImage: BufferedImage) {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "clipboard_image_\(UUID().uuidString).png"
        let fileURL = tempDir.appendingPathComponent(fileName)

        if let tiffData = bufferedImage.image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {

            do {
                try pngData.write(to: fileURL)
                NSWorkspace.shared.open(fileURL)
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }

    private func openText(_ bufferedText: BufferedText) {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "clipboard_text_\(UUID().uuidString).txt"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try bufferedText.text.write(to: fileURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(fileURL)
        } catch {
            print("Failed to save text: \(error)")
        }
    }

    private func openFile(_ bufferedFile: BufferedFile) {
        NSWorkspace.shared.open(bufferedFile.url)
    }

    func copyToClipboard(at index: Int) {
        guard index < content.count else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        let item = content[index]

        switch item.type {
        case .image:
            if let bufferedImage = item as? BufferedImage {
                pasteboard.writeObjects([bufferedImage.image])
            }
        case .text:
            if let bufferedText = item as? BufferedText {
                pasteboard.setString(bufferedText.text, forType: .string)
            }
        case .file:
            if let bufferedFile = item as? BufferedFile {
                pasteboard.writeObjects([bufferedFile.url as NSURL])
            }
        }
    }
}