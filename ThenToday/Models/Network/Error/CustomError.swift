//
//  CustomError.swift
//  ThenToday
//
//  Created by Anton Solovev on 03.02.2025.
//

import Foundation

enum CustomError: Error, Equatable {
    case urlNotValid
    case requestFailed
    case noData
    case decodingError
    case cancelled
    case offline
    case missingAPIConfiguration
}

extension CustomError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .urlNotValid:
            return String(localized: "error_url_invalid")
        case .requestFailed:
            return String(localized: "error_request_failed")
        case .noData:
            return String(localized: "error_no_data")
        case .decodingError:
            return String(localized: "error_decoding")
        case .cancelled:
            return String(localized: "error_cancelled")
        case .offline:
            return String(localized: "error_offline")
        case .missingAPIConfiguration:
            return String(localized: "error_missing_api_keys")
        }
    }
}

extension CustomError {
    static func from(urlError: URLError) -> CustomError {
        switch urlError.code {
        case .cancelled:
            return .cancelled
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .offline
        default:
            return .requestFailed
        }
    }
}
