//
//  ExtendedCoverageTests.swift
//  ThenTodayTests
//

import XCTest
import UIKit
@testable import ThenToday

// MARK: - Stub URLProtocol (shared shape with NetworkingTests)

private final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

/// Emits a fixed `URLError` for every request (offline / cancelled mapping tests).
private final class FailingURLProtocol: URLProtocol {
    static var errorCode: URLError.Code = .notConnectedToInternet

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLError(Self.errorCode))
    }

    override func stopLoading() {}
}

private enum TestPNG {
    /// Valid 1×1 transparent PNG — decodes with `UIImage`.
    static let bytes = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")!
}

// MARK: - CustomError + URLError

final class CustomErrorMappingTests: XCTestCase {
    func testMapsCancelled() {
        XCTAssertEqual(CustomError.from(urlError: URLError(.cancelled)), .cancelled)
    }

    func testMapsOfflineCodes() {
        XCTAssertEqual(CustomError.from(urlError: URLError(.notConnectedToInternet)), .offline)
        XCTAssertEqual(CustomError.from(urlError: URLError(.networkConnectionLost)), .offline)
        XCTAssertEqual(CustomError.from(urlError: URLError(.dataNotAllowed)), .offline)
    }

    func testMapsUnknownURLErrorToRequestFailed() {
        XCTAssertEqual(CustomError.from(urlError: URLError(.badURL)), .requestFailed)
    }
}

// MARK: - AppSecrets

final class AppSecretsTests: XCTestCase {
    func testIsCompleteRequiresBothKeys() {
        XCTAssertFalse(AppSecrets(unsplashAccessKey: "", yandexAPIKey: "k").isComplete)
        XCTAssertFalse(AppSecrets(unsplashAccessKey: "u", yandexAPIKey: "").isComplete)
        XCTAssertTrue(AppSecrets(unsplashAccessKey: "u", yandexAPIKey: "k").isComplete)
    }
}

// MARK: - LanguageMapping edge cases

final class LanguageMappingEdgeCaseTests: XCTestCase {
    func testEmptyLanguagesArray() throws {
        let data = try XCTUnwrap(#"{"languages":[]}"#.data(using: .utf8))
        let response = try JSONDecoder().decode(LanguagesResponse.self, from: data)
        XCTAssertTrue(LanguageMapping.displayLanguages(from: response).isEmpty)
    }
}

// MARK: - NetworkManager Unsplash + decoding

final class NetworkManagerExtendedTests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.handler = nil
        URLProtocol.unregisterClass(StubURLProtocol.self)
        FailingURLProtocol.errorCode = .notConnectedToInternet
        URLProtocol.unregisterClass(FailingURLProtocol.self)
        super.tearDown()
    }

    private func makeSUT() -> NetworkManager {
        URLProtocol.registerClass(StubURLProtocol.self)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let secrets = AppSecrets(unsplashAccessKey: "u_key", yandexAPIKey: "y_key")
        return NetworkManager(session: session, secrets: secrets)
    }

    func testFetchFirstImageDownloadsDecodedThumbnail() async throws {
        let sut = makeSUT()
        let imageHost = "https://images.unsplash.test"
        let photoPath = "/thumb.png"

        StubURLProtocol.handler = { request in
            let u = request.url?.absoluteString ?? ""
            if u.contains("api.unsplash.com") {
                let json = """
                {"results":[{"urls":{"small":"\(imageHost)\(photoPath)"}}]}
                """
                let body = try XCTUnwrap(json.data(using: .utf8))
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }
            if u.hasPrefix(imageHost) {
                XCTAssertEqual(request.url?.path, photoPath)
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, TestPNG.bytes)
            }
            XCTFail("Unexpected URL: \(u)")
            fatalError()
        }

        let image = try await sut.fetchFirstImage(keyword: "sea")
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testFetchFirstImageEmptyResultsThrowsNoData() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            let body = #"{"results":[]}"#.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        do {
            _ = try await sut.fetchFirstImage(keyword: "void")
            XCTFail("expected noData")
        } catch let e as CustomError {
            XCTAssertEqual(e, .noData)
        }
    }

    func testDownloadImageMapsURLSessionFailureToOffline() async throws {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        URLProtocol.registerClass(FailingURLProtocol.self)
        FailingURLProtocol.errorCode = .notConnectedToInternet

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [FailingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let sut = NetworkManager(session: session, secrets: AppSecrets(unsplashAccessKey: "u", yandexAPIKey: "y"))

        let url = URL(string: "https://images.unsplash.test/unreachable.png")!
        do {
            _ = try await sut.downloadImage(from: url)
            XCTFail("expected offline")
        } catch let e as CustomError {
            XCTAssertEqual(e, .offline)
        }
    }

    func testTranslateMalformedJSONThrowsDecodingError() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("translate") ?? false)
            let body = "{".data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        do {
            _ = try await sut.translateText(text: "a", targetLanguage: "ru")
            XCTFail("expected decodingError")
        } catch let e as CustomError {
            XCTAssertEqual(e, .decodingError)
        }
    }

    func testTranslateRequestUsesAuthorizationHeader() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Api-Key y_key")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            let body = #"{"translations":[{"text":"ok"}]}"#.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        let t = try await sut.translateText(text: "hello", targetLanguage: "ru")
        XCTAssertEqual(t, "ok")
    }

    func testTranslateURLErrorMapsToOffline() async throws {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        URLProtocol.registerClass(FailingURLProtocol.self)
        FailingURLProtocol.errorCode = .notConnectedToInternet

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [FailingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let sut = NetworkManager(session: session, secrets: AppSecrets(unsplashAccessKey: "u", yandexAPIKey: "y"))

        do {
            _ = try await sut.translateText(text: "x", targetLanguage: "ru")
            XCTFail("expected offline")
        } catch let e as CustomError {
            XCTAssertEqual(e, .offline)
        }
    }
}

// MARK: - LiveDayExplorationService (fact → translate → Unsplash → image)

@MainActor
final class LiveDayExplorationServiceTests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.handler = nil
        URLProtocol.unregisterClass(StubURLProtocol.self)
        super.tearDown()
    }

    func testExplorationChainsNumbersTranslateUnsplashAndImage() async throws {
        URLProtocol.registerClass(StubURLProtocol.self)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let secrets = AppSecrets(unsplashAccessKey: "uspl", yandexAPIKey: "yndx")
        let network = NetworkManager(session: session, secrets: secrets)
        let sut = LiveDayExplorationService(network: network)

        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 6, day: 15)))

        let imageURLString = "https://cdn.explore.test/photo.png"

        StubURLProtocol.handler = { request in
            let u = request.url?.absoluteString ?? ""

            if u.contains("numbersapi.com") {
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                XCTAssertTrue(u.contains("\(month)/\(day)/date"))
                let body = Data("June 15 is a summer day.".utf8)
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }

            if u.contains("translate.api.cloud.yandex.net") {
                XCTAssertEqual(request.httpMethod, "POST")
                let body = #"{"translations":[{"text":"Июнь"}]}"#.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }

            if u.contains("api.unsplash.com") {
                XCTAssertTrue(u.contains("query="))
                let json = """
                {"results":[{"urls":{"small":"\(imageURLString)"}}]}
                """
                let body = try XCTUnwrap(json.data(using: .utf8))
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }

            if u.hasPrefix("https://cdn.explore.test") {
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, TestPNG.bytes)
            }

            XCTFail("Unexpected request to \(u)")
            fatalError()
        }

        let result = try await sut.exploration(for: date)
        XCTAssertEqual(result.information, "Июнь")
        XCTAssertNotNil(result.image)
    }

    func testExplorationReturnsNilImageWhenUnsplashFails() async throws {
        URLProtocol.registerClass(StubURLProtocol.self)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let secrets = AppSecrets(unsplashAccessKey: "uspl", yandexAPIKey: "yndx")
        let network = NetworkManager(session: session, secrets: secrets)
        let sut = LiveDayExplorationService(network: network)

        let date = Date()

        StubURLProtocol.handler = { request in
            let u = request.url?.absoluteString ?? ""
            if u.contains("numbersapi.com") {
                let body = Data("Fact.".utf8)
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }
            if u.contains("translate") {
                let body = #"{"translations":[{"text":"Слово"}]}"#.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }
            if u.contains("unsplash.com") {
                let body = #"{"results":[]}"#.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, body)
            }
            XCTFail("Unexpected \(u)")
            fatalError()
        }

        let result = try await sut.exploration(for: date)
        XCTAssertEqual(result.information, "Слово")
        XCTAssertNil(result.image)
    }
}
