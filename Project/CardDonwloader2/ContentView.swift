//
//  ContentView.swift
//  CardDonwloader2
//
//  Created by HIROKI IKEUCHI on 2026/01/02.
//

import SwiftUI
import FineJSON

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
            
            Button("Export JSON") {
                let cardRaws = CardStore.shared.cards.map { $0.convertToRaw() }
                /// [Swiftのちょっと便利なJSONのencoderを作った #Swift - Qiita](https://qiita.com/omochimetaru/items/2bf0d8e9f0a0b61c293c#%E3%83%91%E3%83%BC%E3%82%B9%E3%82%A8%E3%83%A9%E3%83%BC%E3%81%8C%E4%BD%8D%E7%BD%AE%E6%83%85%E5%A0%B1%E3%82%92%E6%8C%81%E3%81%A3%E3%81%A6%E3%81%84%E3%82%8B)
                let encoder = FineJSONEncoder()
                guard let jsonValue = try? encoder.encode(cardRaws) else {
                    fatalError("Failed to encode to JSON.")
                }
                try! jsonValue.write(to: URL(filePath: "/Users/ikeh/Programming/Swift/poke-holo-hosting/Project/CardDonwloader2/Card/cards_hikeuchi.json"))
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
