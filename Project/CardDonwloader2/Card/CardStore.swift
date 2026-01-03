//
//  CardStore.swift
//  pokemon-card-demo
//
//  Created by HIROKI IKEUCHI on 2026/01/02.
//

import Foundation

/// 言語のタイトルと色を管理するStore
/// - SeeAlso: [github-colors/colors.json](https://github.com/ozh/github-colors/blob/master/colors.json)
@MainActor
@Observable
final class CardStore {

    // MARK: - Properties

    static let shared: CardStore = .init()
    
    let cards: [Card]

    // MARK: - LifeCycle

    private init() {
        do {
            self.cards = try Self.loadCardsFromResources()
        } catch {
            print(error.localizedDescription)
            self.cards = []
        }
    }
    
    // MARK: Setup

    /// cards.json からカードデータを読み込む
    static func loadCardsFromResources() throws -> [Card] {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json") else {
            throw NSError(domain: "JSON", code: 1, userInfo: [NSLocalizedDescriptionKey: "cards.json が見つかりません"])
        }
        let data = try Data(contentsOf: url)
        let cardRaws = try JSONDecoder().decode([CardRaw].self, from: data)
        let cards = cardRaws.map { Card($0) }
        
        cards.forEach { card in
            print("【\(card.name)】")
            print("\(card.images.large)")
            print("\(card.images.small)")
            if let foil = card.images.foilURL {
                print(foil.absoluteString)
            }
            if let mask = card.images.maskURL {
                print(mask.absoluteString)
            }
            print("\n")
        }
        return cards
    }
    
    // MARK: - Read
    
    /// Common/Uncommon
    /// テクスチャ: 無し
    var commonUncommonCard: [Card] {
        let cards = cards.filter({
            ($0.rarity == .common || $0.rarity == .uncommon) &&
            $0.images.foil == nil &&
            $0.images.mask == nil
        })
        return cards
    }
    
    /// reverseHoloNonRares
    /// テクスチャ無し
    var reverseHoloNonRares: [Card] {
        let cards = cards.filter({
            ($0.rarity == .common || $0.rarity == .uncommon) &&
            $0.images.foil == nil &&
            $0.images.mask == nil
        })
        return cards
    }
    
    /// Holofoil Rare
    var holofoilRareCard: [Card] {
        let cards = cards.filter({
            $0.rarity == .rareHolo &&
            $0.images.foil != nil &&
            $0.images.mask != nil
        })
        return cards
    }
    
    /// Galaxy/Cosmos Holofoil
    var rareHoloCosmosCard: [Card] {
        let cards = cards.filter({
            $0.rarity == .rareHoloCosmos &&
            $0.images.foil != nil &&
            $0.images.mask != nil
        })
                        
        return cards
    }
}

// MARK: - Preview

