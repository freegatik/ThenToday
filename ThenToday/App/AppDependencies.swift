//
//  AppDependencies.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import UIKit

@MainActor
final class AppDependencies {
    let networkManager: NetworkManager
    let dayExploration: DayExplorationService
    private let translateClient: YandexTranslateClient

    init(secrets: AppSecrets = .load(), session: URLSession = .appShared) {
        if UITestingConfiguration.isUITesting {
            let placeholderSecrets = AppSecrets(unsplashAccessKey: "uitest", yandexAPIKey: "uitest")
            let network = NetworkManager(session: session, secrets: placeholderSecrets)
            self.networkManager = network
            if UITestingConfiguration.forceExplorationFailure {
                self.dayExploration = UITestingFailingExplorationService()
            } else {
                self.dayExploration = UITestingStubExplorationService()
            }
            self.translateClient = UITestingStubTranslateClient()
        } else {
            let network = NetworkManager(session: session, secrets: secrets)
            self.networkManager = network
            self.dayExploration = LiveDayExplorationService(network: network)
            self.translateClient = network
        }
    }

    func makeDatePickerViewController() -> DatePickerViewController {
        DatePickerViewController(dayExploration: dayExploration, translateClient: translateClient)
    }

    func makeDateInformationViewController(information: String, image: UIImage) -> DateInformationViewController {
        DateInformationViewController(information: information, image: image, translateClient: translateClient)
    }
}
