//
//  AccessibilityAuditTests.swift
//  ThenTodayTests
//
//  Created by Anton Solovev on 10.05.2026.
//

import XCTest

@testable import ThenToday

@MainActor
final class AccessibilityAuditTests: XCTestCase {
    func test_datePicker_requiredAccessibilityIds() {
        let vc = AppDependencies().makeDatePickerViewController()
        vc.loadViewIfNeeded()

        XCTAssertEqual(vc.datePicker.accessibilityIdentifier, "datePicker")
        XCTAssertFalse(vc.datePicker.accessibilityLabel?.isEmpty ?? true)

        XCTAssertEqual(vc.button.accessibilityIdentifier, "findOutButton")
        XCTAssertTrue(vc.button.accessibilityTraits.contains(.button))

        XCTAssertEqual(vc.titleLabel.accessibilityIdentifier, "mainTitle")
        XCTAssertTrue(vc.titleLabel.accessibilityTraits.contains(.header))

        XCTAssertEqual(vc.titleImage.accessibilityIdentifier, "titleMarkImage")
        XCTAssertTrue(vc.titleImage.accessibilityTraits.contains(.image))
    }

    func test_detail_factLabelAndPickersIdentified() {
        let sut = DateInformationViewController(
            information: "Fact",
            image: UIImage(systemName: "star.fill") ?? UIImage(),
            translateClient: UITestingStubTranslateClient()
        )
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.informationLabel.accessibilityIdentifier, "factLabel")
        XCTAssertEqual(sut.languagePicker.accessibilityIdentifier, "languagePicker")
    }
}
