//
//  TranslateResponse.swift
//  ThenToday
//
//  Created by Anton Solovev on 14.02.2025.
//

import Foundation

struct TranslateResponse: Decodable {
    let translations: [Translation]
    
    struct Translation: Decodable {
        let text: String
    }
}
