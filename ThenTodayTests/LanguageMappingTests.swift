//
//  LanguageMappingTests.swift
//  ThenTodayTests
//
//  Created by Anton Solovev on 01.02.2025.
//

import XCTest
@testable import ThenToday

final class LanguageMappingTests: XCTestCase {
    func testDisplayLanguagesFiltersInvalidEntries() throws {
        let json = """
        {"languages":[
          {"code":"en","name":"English"},
          {"code":"","name":"Bad"},
          {"code":"ru","name":"Русский"},
          {"code":"de","name":""}
        ]}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let response = try JSONDecoder().decode(LanguagesResponse.self, from: data)
        let languages = LanguageMapping.displayLanguages(from: response)
        XCTAssertEqual(languages.count, 2)
        XCTAssertEqual(languages.compactMap(\.code), ["en", "ru"])
    }
}
