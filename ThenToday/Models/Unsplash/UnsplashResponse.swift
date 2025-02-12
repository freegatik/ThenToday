//
//  UnsplashResponse.swift
//  ThenToday
//
//  Created by Anton Solovev on 12.02.2025.
//

import Foundation

struct UnsplashResponse: Decodable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Decodable {
    let urls: UnsplashPhotoURLs
}

struct UnsplashPhotoURLs: Decodable {
    let small: String
}
