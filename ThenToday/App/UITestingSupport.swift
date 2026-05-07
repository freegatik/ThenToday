//
//  UITestingSupport.swift
//  ThenToday
//

import UIKit

enum UITestingConfiguration {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
    }

    static var forceExplorationFailure: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITestingNetworkError")
    }
}

@MainActor
final class UITestingStubExplorationService: DayExplorationService {
    func exploration(for date: Date) async throws -> DayExplorationResult {
        _ = date
        let img = UIImage(systemName: "sun.max")
        return DayExplorationResult(
            information: "UI test: sample fact for selected date.",
            image: img
        )
    }
}

@MainActor
final class UITestingFailingExplorationService: DayExplorationService {
    func exploration(for date: Date) async throws -> DayExplorationResult {
        _ = date
        throw CustomError.requestFailed
    }
}

final class UITestingStubTranslateClient: YandexTranslateClient {
    func getLanguagesList() async throws -> [Language] {
        let json = """
        {"languages":[
          {"code":"en","name":"English"},
          {"code":"ru","name":"Русский"}
        ]}
        """
        let data = Data(json.utf8)
        let response = try JSONDecoder().decode(LanguagesResponse.self, from: data)
        return LanguageMapping.displayLanguages(from: response)
    }

    func translateText(text: String, targetLanguage: String) async throws -> String {
        "[\(targetLanguage)] \(text)"
    }
}
