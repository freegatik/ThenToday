//
//  LanguagesResponse.swift
//  ThenToday
//
//  Created by Anton Solovev on 16.02.2025.
//

import Foundation

struct LanguagesResponse: Decodable {
    let languages: [Language]
}

struct Language: Decodable {
    let code: String?
    let name: String?
}
