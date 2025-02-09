//
//  NetworkManagerUnsplash.swift
//  ThenToday
//
//  Created by Anton Solovev on 08.02.2025.
//

import Foundation
import UIKit

// MARK: - Unsplash API
extension NetworkManager {
    func fetchFirstImage(keyword: String) async throws -> UIImage {
        let api = Api.photo(keyword: keyword, accessKey: secrets.unsplashAccessKey)
        let response = try await fetch(api: api, resultType: UnsplashResponse.self)
        guard let firstPhoto = response.results.first, let imageURL = URL(string: firstPhoto.urls.small) else {
            throw CustomError.noData
        }
        return try await downloadImage(from: imageURL)
    }

    func downloadImage(from url: URL) async throws -> UIImage {
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw CustomError.noData
            }
            return image
        } catch let urlError as URLError {
            throw CustomError.from(urlError: urlError)
        } catch {
            throw CustomError.requestFailed
        }
    }
}
