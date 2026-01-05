//
//  Card.swift
//  pokemon-card-demo
//
//  Created by HIROKI IKEUCHI on 2025/11/18.
//

import Foundation

// MARK: - カードの属性

/// カードのタイプ (ポケモン・トレーナー・エネルギー)
enum CardSupertype: String, Codable {
    case pokemon = "Pokémon"
    case trainer = "Trainer"
    case energy = "Energy"
    case unknown = "Unknown" // 通常利用されない
}

/// カードのエネルギータイプ)
enum CardType: String, Codable {
    case grass = "Grass"
    case fire = "Fire"
    case water = "Water"
    case lightning = "Lightning"
    case psychic = "Psychic"
    case fighting = "Fighting"
    case darkness = "Darkness"
    case metal = "Metal"
    case dragon = "Dragon"
    case colorless = "Colorless"
    case unknown = "Unknown" // 通常利用されない
}

/// カードのサブタイプ
enum CardSubtype: String, Codable {
    case basic = "Basic"
    case stage1 = "Stage 1"
    case stage2 = "Stage 2"
    case supporter = "Supporter"
    case special = "Special"
    case stadium = "Stadium"
    case v = "V"
    case vmax = "VMAX"
    case vstar = "VSTAR"
    case radiant = "Radiant"
    case rapidStrike = "Rapid Strike"
    case singleStrike = "Single Strike"
    case fusionStrike = "Fusion Strike"
    case item = "Item"
    case unknown = "Unknown" // 通常利用されない
}

/// カードのレアリティ
enum CardRarity: String, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rareHolo = "Rare Holo"
    case rareHoloCosmos = "Rare Holo Cosmos"
    case radiantRare = "Radiant Rare"
    case trainerGalleryRareHolo = "Trainer Gallery Rare Holo"
    case rareHoloV = "Rare Holo V"
    case rareHoloVMAX = "Rare Holo VMAX"
    case rareHoloVSTAR = "Rare Holo VSTAR"
    case rareUltra = "Rare Ultra"
    case rareRainbow = "Rare Rainbow"
    case amazingRare = "Amazing Rare"
    case rareShiny = "Rare Shiny"
    case rareSecret = "Rare Secret"
    case unknown = "Unknown" // 通常利用されない
}

// MARK: - カードのモデル

struct Card: Codable, Identifiable {
    
    // MARK: - Types
    
    struct CardImages: Codable {
        let small: URL
        let large: URL
        // 一部の行だけに存在する追加フィールド（ローカル相対パス想定）
        let foil: String? // 相対パス
        let mask: String?
        
        var foilURL: URL? {
            guard let foil else {
                return nil
            }
            return URL(string: Card.buildFoilPath(relativePath: foil))
        }
        
        var maskURL: URL? {
            guard let mask else {
                return nil
            }
            return URL(string: Card.buildMaskPath(relativePath: mask))
        }
        
//        /*
//         /img/foils/swsh12/foils/127_foil_holo_reverse.jpg
//         -> https://poke-holo.b-cdn.net/foils/swsh12/foils/upscaled/127_foil_holo_reverse_2x.webp
//         
//            https://poke-holo.b-cdn.net/masks/upscaled/swsh12/masks/upscaled/127_foil_holo_reverse.jpg
//         */
//        var foilPath: String? {
//            guard let foil else {
//                return nil
//            }
//            return foil
//                .replacingOccurrences(of: "/img", with: "https://poke-holo.b-cdn.net")
//                .replacingOccurrences(of: "masks/", with: "masks/upscaled/")
//                .replacingOccurrences(of: ".png", with: "_2x.webp")
//        }
//        
//        /*
//         /img/foils/swsh12/masks/127_foil_holo_reverse.png
//         -> https://poke-holo.b-cdn.net/foils/swsh12/masks/upscaled/127_foil_holo_reverse_2x.webp
//         */
//        var maskPath: String? {
//            guard let foil else {
//                return nil
//            }
//            return foil
//                .replacingOccurrences(of: "/img", with: "https://poke-holo.b-cdn.net")
//                .replacingOccurrences(of: "masks/", with: "masks/upscaled/")
//                .replacingOccurrences(of: ".png", with: "_2x.webp")
//        }
    }
    
    // MARK: - Property
    
    let id: String
    let set: String
    let name: String
    let supertype: CardSupertype
    let subtypes: [CardSubtype]?
    let types: [CardType]?
    let number: String
    let rarity: CardRarity?
    let images: CardImages
        
    // MARK: - Translator
        
    /// CardRaw -> Card
    init(_ raw: CardRaw) {
        self.id = raw.id
        self.set = raw.set
        self.name = raw.name
        self.supertype = .init(rawValue: raw.supertype) ?? .unknown
        self.subtypes = raw.subtypes?.compactMap { CardSubtype(rawValue: $0) }
        self.types = raw.types?.compactMap { CardType(rawValue: $0) }
        self.number = raw.number
        self.rarity = raw.rarity.flatMap { CardRarity(rawValue: $0) }

        self.images = .init(
            small: URL(string: raw.images.small)!,
            large: URL(string: raw.images.large)!,
            foil: raw.images.foil,
            mask: raw.images.mask
        )
    }
}

extension Card {
    /*
     /img/foils/swsh12/foils/127_foil_holo_reverse.jpg
     -> https://poke-holo.b-cdn.net/foils/swsh12/foils/upscaled/127_foil_holo_reverse_2x.webp
     */
    static func buildFoilPath(relativePath: String) -> String {
        let components = relativePath.split(separator: "/").map { String($0) }
        return [
            "https://poke-holo.b-cdn.net",
            components[1], // foils
            components[2], // swsh12
            components[3], // foils
            "upscaled",
            components[4].replacingOccurrences(of: ".jpg", with: "").appending("_2x.webp"),
        ]
            .joined(separator: "/")
    }

    /*
     /img/foils/swsh12/masks/127_foil_holo_reverse.png
     -> https://poke-holo.b-cdn.net/foils/swsh12/masks/upscaled/127_foil_holo_reverse_2x.webp
     */
    static  func buildMaskPath(relativePath: String) -> String {
        let components = relativePath.split(separator: "/").map { String($0) }
        return [
            "https://poke-holo.b-cdn.net",
            components[1], // foils
            components[2], // swsh12
            components[3], // masks
            "upscaled",
            components[4].replacingOccurrences(of: ".jpg", with: "")
                .replacingOccurrences(of: ".png", with: "")
                .appending("_2x.webp"),
        ]
            .joined(separator: "/")
    }
}

// MARK: - JSON読み込み

extension Card {
    /// cards.json からカードデータを読み込む
    static func loadCards() throws -> [Card] {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json") else {
            throw NSError(domain: "JSON", code: 1, userInfo: [NSLocalizedDescriptionKey: "cards.json が見つかりません"])
        }
        let data = try Data(contentsOf: url)
        let cardRaws = try JSONDecoder().decode([CardRaw].self, from: data)
        let cards = cardRaws.map { Card($0) }
        
        _ = cards.map { card in
            print("【\(card.name)】")
            print("\(card.images.large)")
            print("\(card.images.small)")
            print("\(card.images.foil ?? "nil")")
            print("\(card.images.mask ?? "nil")")
            print("\n")
        }
        return cards
    }
}

// MARK: - Convert to CardRaw

extension Card {
    func convertToRaw() -> CardRaw {
        
        // https://pommdau.github.io/poke-holo-hosting/CardDownloader/pgo/11/11_foil.webp
        let baseURL = URL(string: "https://pommdau.github.io/poke-holo-hosting/CardDownloader")!
        let baseDirectory = baseURL
            .appending(path: self.set)
            .appending(path: self.number)
        
        let imagesSmall = baseDirectory
            .appending(path: "\(self.number)_small")
            .appendingPathExtension(self.images.small.pathExtension)
        
        let imagesLarge = baseDirectory
            .appending(path: "\(self.number)_large")
            .appendingPathExtension(self.images.large.pathExtension)
        
        let imagesFoil: URL?
        if let foil = self.images.foilURL {
            imagesFoil = baseDirectory
               .appending(path: "\(self.number)_foil")
               .appendingPathExtension(foil.pathExtension)
        } else {
            imagesFoil = nil
        }        
        let imagesMask: URL?
        if let mask = self.images.maskURL {
            imagesMask = baseDirectory
               .appending(path: "\(self.number)_mask")
               .appendingPathExtension(mask.pathExtension)
        } else {
            imagesMask = nil
        }
        let images: CardRaw.CardImages = .init(
            small: imagesSmall.absoluteString,
            large: imagesLarge.absoluteString,
            foil: imagesFoil?.absoluteString,
            mask: imagesMask?.absoluteString
        )
        return .init(
            id: self.id,
            set: self.set,
            name: self.name,
            supertype: self.supertype.rawValue,
            subtypes: self.subtypes?.map { $0.rawValue },
            types: self.types?.map { $0.rawValue },
            number: self.number,
            rarity: self.rarity?.rawValue,
            images: images
        )
    }
}

// MARK: - Preview

import SwiftUI

private struct PreviewView: View {
    
    @State private var cards: [Card] = []
    
    var body: some View {
        VStack {
            List(cards) { card in                                
                VStack(alignment: .leading) {
                    Text(card.name)
                    Text("Rairity: \(card.rarity?.rawValue ?? "N/A")")
                    Text("large: \(card.images.large)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)   // 最小 50% まで縮小
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
//            guard let card = try? Card.loadCards() else {
//                return
//            }
//            self.cards = card
            _ = print(Card.buildFoilPath(relativePath: "/img/foils/swsh12/foils/127_foil_holo_reverse.jpg"))
        }
    }
}

#Preview {
    PreviewView()
}
