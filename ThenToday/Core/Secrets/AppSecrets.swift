//
//  AppSecrets.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import Foundation

// Keys: UNSPLASH_ACCESS_KEY, YANDEX_API_KEY from env or Info.plist (never commit values).
struct AppSecrets: Sendable {
    let unsplashAccessKey: String
    let yandexAPIKey: String

    init(unsplashAccessKey: String, yandexAPIKey: String) {
        self.unsplashAccessKey = unsplashAccessKey
        self.yandexAPIKey = yandexAPIKey
    }

    static func load() -> AppSecrets {
        func read(_ key: String) -> String {
            if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
                return value
            }
            if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty {
                return value
            }
            return ""
        }

        return AppSecrets(
            unsplashAccessKey: read("UNSPLASH_ACCESS_KEY"),
            yandexAPIKey: read("YANDEX_API_KEY")
        )
    }

    var isComplete: Bool {
        !unsplashAccessKey.isEmpty && !yandexAPIKey.isEmpty
    }
}
