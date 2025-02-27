//
//  NetworkingTests.swift
//  ThenTodayTests
//

import XCTest
@testable import ThenToday

// MARK: - Api

final class ApiTests: XCTestCase {
    func testDateEndpointAndMethod() {
        let api = Api.date(month: 3, day: 14)
        XCTAssertEqual(api.baseURL + api.endpoint, "http://numbersapi.com/3/14/date")
        if case .get = api.method {} else { XCTFail("expected GET") }
    }

    func testTranslateEndpointUsesPost() {
        let api = Api.translate(text: "hi", targetLanguage: "ru", apiKey: "secret")
        XCTAssertEqual(api.endpoint, "translate/v2/translate")
        XCTAssertTrue(api.baseURL.hasPrefix("https://translate.api.cloud.yandex.net/"))
        if case .post = api.method {} else { XCTFail("expected POST") }
    }

    func testLanguagesEndpointUsesPost() {
        let api = Api.languages(apiKey: "k")
        XCTAssertEqual(api.endpoint, "translate/v2/languages")
        if case .post = api.method {} else { XCTFail("expected POST") }
    }

    func testPhotoQueryIncludesAccessKey() {
        let api = Api.photo(keyword: "sun", accessKey: "abc")
        XCTAssertTrue(api.baseURL.contains("unsplash"))
        XCTAssertTrue(api.endpoint.contains("query=sun"))
        XCTAssertTrue(api.endpoint.contains("client_id=abc"))
        if case .get = api.method {} else { XCTFail("expected GET") }
    }
}

// MARK: - TranslateResponse

final class TranslateResponseDecodingTests: XCTestCase {
    func testDecodeTranslations() throws {
        let json = #"{"translations":[{"text":"здравствуй"}]}"#
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(TranslateResponse.self, from: data)
        XCTAssertEqual(decoded.translations.count, 1)
        XCTAssertEqual(decoded.translations.first?.text, "здравствуй")
    }
}

// MARK: - URLProtocol stub

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

// MARK: - NetworkManager

final class NetworkManagerURLProtocolTests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.handler = nil
        URLProtocol.unregisterClass(StubURLProtocol.self)
        super.tearDown()
    }

    private func makeSUT() -> NetworkManager {
        URLProtocol.registerClass(StubURLProtocol.self)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let secrets = AppSecrets(unsplashAccessKey: "u", yandexAPIKey: "k")
        return NetworkManager(session: session, secrets: secrets)
    }

    func testMissingSecretsThrows() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let sut = NetworkManager(session: session, secrets: AppSecrets(unsplashAccessKey: "", yandexAPIKey: ""))
        do {
            _ = try await sut.fetchForDate(date: Date())
            XCTFail("expected missingAPIConfiguration")
        } catch let error as CustomError {
            XCTAssertEqual(error, .missingAPIConfiguration)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testTranslateReturnsFirstTranslation() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("translate") ?? false)
            let body = #"{"translations":[{"text":"да"}]}"#.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, body)
        }
        let text = try await sut.translateText(text: "yes", targetLanguage: "ru")
        XCTAssertEqual(text, "да")
    }

    func testTranslateEmptyTranslationsThrowsNoData() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            let body = #"{"translations":[]}"#.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        do {
            _ = try await sut.translateText(text: "x", targetLanguage: "ru")
            XCTFail("expected noData")
        } catch let error as CustomError {
            XCTAssertEqual(error, .noData)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testNonSuccessHTTPThrowsRequestFailed() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            let body = Data()
            let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        do {
            _ = try await sut.translateText(text: "x", targetLanguage: "ru")
            XCTFail("expected requestFailed")
        } catch let error as CustomError {
            XCTAssertEqual(error, .requestFailed)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testFetchForDatePlainText() async throws {
        let sut = makeSUT()
        let calendar = Calendar.current
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 7, day: 4)))
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        StubURLProtocol.handler = { request in
            let expectedPath = "\(month)/\(day)/date"
            XCTAssertTrue(request.url?.absoluteString.contains(expectedPath) ?? false, request.url?.absoluteString ?? "")
            let body = Data("July 4 is Independence Day.".utf8)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        let fact = try await sut.fetchForDate(date: date)
        XCTAssertEqual(fact, "July 4 is Independence Day.")
    }

    func testGetLanguagesListAppliesMapping() async throws {
        let sut = makeSUT()
        StubURLProtocol.handler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("languages") ?? false)
            let json = """
            {"languages":[
              {"code":"en","name":"English"},
              {"code":"","name":"Bad"},
              {"code":"fr","name":"Français"}
            ]}
            """
            let body = try XCTUnwrap(json.data(using: .utf8))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body)
        }
        let languages = try await sut.getLanguagesList()
        XCTAssertEqual(languages.map(\.code), ["en", "fr"])
    }
}
