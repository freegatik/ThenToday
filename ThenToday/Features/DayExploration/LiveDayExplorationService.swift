//
//  LiveDayExplorationService.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import UIKit

@MainActor
final class LiveDayExplorationService: DayExplorationService {
    private let network: NetworkManager

    init(network: NetworkManager) {
        self.network = network
    }

    func exploration(for date: Date) async throws -> DayExplorationResult {
        let fact = try await network.fetchForDate(date: date)
        let translated = try await network.translateText(text: fact, targetLanguage: "ru")
        let image = try? await network.fetchFirstImage(keyword: translated)
        return DayExplorationResult(information: translated, image: image)
    }
}
