//
//  NetworkManagerYandex.swift
//  ThenToday
//
//  Created by Anton Solovev on 09.02.2025.
//

import Foundation

// MARK: - Yandex Translate API
extension NetworkManager {
    func translateText(text: String, targetLanguage: String) async throws -> String {
        let api = Api.translate(text: text, targetLanguage: targetLanguage, apiKey: secrets.yandexAPIKey)
        let response = try await fetch(api: api, resultType: TranslateResponse.self)
        guard let translatedText = response.translations.first?.text else {
            throw CustomError.noData
        }
        return translatedText
    }

    func getLanguagesList() async throws -> [Language] {
        let api = Api.languages(apiKey: secrets.yandexAPIKey)
        let response = try await fetch(api: api, resultType: LanguagesResponse.self)
        return LanguageMapping.displayLanguages(from: response)
    }
}

extension NetworkManager: YandexTranslateClient {}
