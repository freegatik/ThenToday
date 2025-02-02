//
//  DayExplorationService.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import UIKit

struct DayExplorationResult {
    let information: String
    let image: UIImage?
}

// MARK: - DayExplorationService

@MainActor
protocol DayExplorationService: AnyObject {
    func exploration(for date: Date) async throws -> DayExplorationResult
}
