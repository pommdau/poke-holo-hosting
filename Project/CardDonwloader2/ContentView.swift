//
//  ContentView.swift
//  CardDonwloader2
//
//  Created by HIROKI IKEUCHI on 2026/01/02.
//

import SwiftUI

struct ContentView: View {
    
    var downloadsDirectoryURL: URL {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Download") {
                Task {
                    do {
                        for card in CardStore.shared.cards {
                            try await downloadCardImages(card: card)
                            try? await Task.sleep(for: .seconds(1))
                        }
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        .padding()
    }
    
    func downloadCardImages(card: Card) async throws {
        
        /*
         "small": "https://images.pokemontcg.io/swshp/SWSH127.png",
         "large": "https://images.pokemontcg.io/swshp/SWSH127_hires.png",
         "foil": "/img/foils/swshp/foils/127_foil_holo_cosmos.jpg",
         "mask": "/img/foils/swshp/masks/127_foil_holo_cosmos.png"
         */
        
//        let outputDirectory = downloadsDirectoryURL
//            .appending(path: "CardDownloader")
//            .appending(path: card.set)
//            .appending(path: card.number)
        let downloadCardTask = DownloadCardTask(card: card)
        try await downloadCardTask.largeDownloadURLs.download()
        try await downloadCardTask.smallDownloadURLs.download()
        try await downloadCardTask.foilDownloadURLs?.download()
        try await downloadCardTask.maskDownloadURLs?.download()
    }
}

struct DownloadCardTask {
    
    struct DownloadURLs {
        let downloadURL: URL
        let saveURL: URL
        
        func download() async throws {
            
            // すでにファイルがある場合は何もしない
            if FileManager.default.fileExists(atPath: saveURL.path()) {
                return
            }
            
            let (tempURL, _) = try await URLSession.shared.download(from: downloadURL)
            
            // フォルダが存在しなければ作成
            let outputDirectoryURL = saveURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: outputDirectoryURL.path()) {
                try FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true)
            }
            
            try FileManager.default.moveItem(at: tempURL, to: saveURL)
        }
    }
    
    let card: Card
        
    var downloadsDirectoryURL: URL {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }
    
    var cardRootDirectoryURL: URL {
        downloadsDirectoryURL
            .appending(path: "CardDownloader")
            .appending(path: card.set)
            .appending(path: card.number)
    }
    
    var largeDownloadURLs: DownloadURLs {
        let downloadURL = card.images.large
        return .init(
            downloadURL: downloadURL,
            saveURL: cardRootDirectoryURL
                .appendingPathComponent("\(card.number)_large")
                .appendingPathExtension(downloadURL.pathExtension)
        )
    }
    
    var smallDownloadURLs: DownloadURLs {
        let downloadURL = card.images.small
        return .init(
            downloadURL: downloadURL,
            saveURL: cardRootDirectoryURL
                .appendingPathComponent("\(card.number)_small")
                .appendingPathExtension(downloadURL.pathExtension)
        )
    }
    
    var foilDownloadURLs: DownloadURLs? {
        guard let downloadURL = card.images.foilURL else {
            return nil
        }
        return .init(
            downloadURL: downloadURL,
            saveURL: cardRootDirectoryURL
                .appendingPathComponent("\(card.number)_foil")
                .appendingPathExtension(downloadURL.pathExtension)
        )
    }
    
    var maskDownloadURLs: DownloadURLs? {
        guard let downloadURL = card.images.maskURL else {
            return nil
        }
        return .init(
            downloadURL: downloadURL,
            saveURL: cardRootDirectoryURL
                .appendingPathComponent("\(card.number)_mask")
                .appendingPathExtension(downloadURL.pathExtension)
        )
    }
}

#Preview {
    ContentView()
}
