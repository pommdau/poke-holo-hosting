//
//  CardRaw.swift
//  pokemon-card-demo
//
//  Created by HIROKI IKEUCHI on 2025/10/21.
//

import Foundation

// MARK: - CardRaw

/// JSONと対応するカードのデータモデル
struct CardRaw: Codable, Identifiable {
    let id: String
    let set: String
    let name: String
    let supertype: String
    let subtypes: [String]?
    let types: [String]?
    let number: String
    let rarity: String?
    let images: CardImages
    
    struct CardImages: Codable {
        let small: URL
        let large: URL
        // 一部の行だけに存在する追加フィールド（ローカル相対パス想定）
        let foil: String?
        let mask: String?
    }
}
