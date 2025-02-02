//
//  YandexTranslateClient.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import Foundation

protocol YandexTranslateClient: AnyObject {
    func getLanguagesList() async throws -> [Language]
    func translateText(text: String, targetLanguage: String) async throws -> String
}
