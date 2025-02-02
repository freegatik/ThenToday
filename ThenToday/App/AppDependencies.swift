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

    init(secrets: AppSecrets = .load(), session: URLSession = .appShared) {
        let network = NetworkManager(session: session, secrets: secrets)
        self.networkManager = network
        self.dayExploration = LiveDayExplorationService(network: network)
    }

    func makeDatePickerViewController() -> DatePickerViewController {
        DatePickerViewController(dayExploration: dayExploration, translateClient: networkManager)
    }

    func makeDateInformationViewController(information: String, image: UIImage) -> DateInformationViewController {
        DateInformationViewController(information: information, image: image, translateClient: networkManager)
    }
}
