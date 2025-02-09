//
//  NetworkManager.swift
//  ThenToday
//
//  Created by Anton Solovev on 06.02.2025.
//

import Foundation
import UIKit

// MARK: - Network Manager
final class NetworkManager {
    let session: URLSession
    let secrets: AppSecrets

    init(session: URLSession = .appShared, secrets: AppSecrets = .load()) {
        self.session = session
        self.secrets = secrets
    }

    func fetch<T: Decodable>(api: Api, resultType: T.Type) async throws -> T {
        guard secrets.isComplete else {
            throw CustomError.missingAPIConfiguration
        }

        let urlString = api.baseURL + api.endpoint
        guard let url = URL(string: urlString) else {
            throw CustomError.urlNotValid
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = api.method.rawValue

        if case let .post(request) = api.method {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(request)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("Api-Key \(secrets.yandexAPIKey)", forHTTPHeaderField: "Authorization")
            } catch {
                throw CustomError.decodingError
            }
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw CustomError.from(urlError: urlError)
        } catch {
            throw CustomError.requestFailed
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw CustomError.requestFailed
        }

        if resultType == String.self, let string = String(data: data, encoding: .utf8) {
            return string as! T
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CustomError.decodingError
        }
    }
}
