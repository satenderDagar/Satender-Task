//
//  CoinData.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import Foundation

enum CryptoType: String, Codable {
    case token
    case coin
}

struct CoinData: Codable, Equatable {
    let name: String
    let symbol: String
    let isNew: Bool
    let isActive: Bool
    let type: CryptoType
    lazy var imageName: String  = {
        var imageName: String
        
        switch type {
        case .token:
            imageName = ImageConstants.tokenActive
        case .coin:
            imageName = ImageConstants.coinActive
        }
        
        imageName = isActive ? imageName : ImageConstants.isInactive
        return imageName
    }()
    
    enum CodingKeys: String, CodingKey {
        case name
        case symbol
        case isNew = "is_new"
        case isActive = "is_active"
        case type
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        let type = try container.decode(String.self, forKey: .type)
        if let cryptoType = CryptoType(rawValue: type) {
            self.type = cryptoType
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid CryptoType")
        }
    }
}
