//
//  URLSessionConfiguration+App.swift
//  ThenToday
//
//  Created by Anton Solovev on 01.02.2025.
//

import Foundation

extension URLSessionConfiguration {
    static var appNetworking: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 25
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return configuration
    }
}

extension URLSession {
    static var appShared: URLSession {
        URLSession(configuration: .appNetworking)
    }
}
