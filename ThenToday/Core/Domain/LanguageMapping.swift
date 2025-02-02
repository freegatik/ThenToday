//
//  LanguageMapping.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import Foundation

enum LanguageMapping {
    static func displayLanguages(from response: LanguagesResponse) -> [Language] {
        response.languages.compactMap { language in
            guard let code = language.code, !code.isEmpty,
                  let name = language.name, !name.isEmpty else { return nil }
            return Language(code: code, name: name)
        }
    }
}
