//
//  TranslateRequest.swift
//  ThenToday
//
//  Created by Anton Solovev on 13.02.2025.
//

import Foundation

struct TranslateRequest: Encodable {
    let texts: [String]
    let targetLanguageCode: String
    
    init(text: String, targetLanguage: String) {
        self.texts = [text]
        self.targetLanguageCode = targetLanguage
    }
}
