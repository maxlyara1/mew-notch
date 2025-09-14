//
//  ClipboardBufferView.swift
//  MewNotch
//
//  Created by Assistant on 14/09/25.
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ClipboardBufferView: View {
    @StateObject private var viewModel = ClipboardBufferViewModel()
    @State private var isDraggingOver = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isDraggingOver ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )

                    if index < viewModel.content.count {
                        let item = viewModel.content[index]

                        switch item.type {
                        case .image:
                            if let bufferedImage = item as? BufferedImage {
                                Image(nsImage: bufferedImage.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 66, height: 66)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .draggable(bufferedImage)
                                    .onTapGesture {
                                        viewModel.openContent(at: index)
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            viewModel.copyToClipboard(at: index)
                                        }) {
                                            Label("Копировать", systemImage: "doc.on.doc")
                                        }
                                        Button(action: {
                                            viewModel.removeContent(at: index)
                                        }) {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                            }

                        case .text:
                            if let bufferedText = item as? BufferedText {
                                VStack(spacing: 4) {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 24))
                                    Text(String(bufferedText.text.prefix(10)) + (bufferedText.text.count > 10 ? "..." : ""))
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(width: 66, height: 66)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .draggable(bufferedText)
                                .onTapGesture {
                                    viewModel.openContent(at: index)
                                }
                                .contextMenu {
                                    Button(action: {
                                        viewModel.copyToClipboard(at: index)
                                    }) {
                                        Label("Копировать", systemImage: "doc.on.doc")
                                    }
                                    Button(action: {
                                        viewModel.removeContent(at: index)
                                    }) {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }

                        case .file:
                            if let bufferedFile = item as? BufferedFile {
                                VStack(spacing: 4) {
                                    Image(systemName: "doc")
                                        .foregroundColor(.green)
                                        .font(.system(size: 24))
                                    Text(bufferedFile.name)
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(width: 66, height: 66)
                                .background(Color.green.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .draggable(bufferedFile)
                                .onTapGesture {
                                    viewModel.openContent(at: index)
                                }
                                .contextMenu {
                                    Button(action: {
                                        viewModel.copyToClipboard(at: index)
                                    }) {
                                        Label("Копировать", systemImage: "doc.on.doc")
                                    }
                                    Button(action: {
                                        viewModel.removeContent(at: index)
                                    }) {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.system(size: 28))
                    }
                }
                .onDrop(of: [.image, .fileURL, .utf8PlainText, .plainText, .url, .text], isTargeted: $isDraggingOver) { providers in
                    viewModel.handleDrop(providers: providers, at: index)
                    return true
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .cornerRadius(10)
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
}