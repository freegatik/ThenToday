//
//  NetworkManagerNumbers.swift
//  ThenToday
//
//  Created by Anton Solovev on 07.02.2025.
//

import Foundation

// MARK: - Numbers API
extension NetworkManager {
    func fetchForDate(date: Date) async throws -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let api = Api.date(month: month, day: day)
        return try await fetch(api: api, resultType: String.self)
    }
}
