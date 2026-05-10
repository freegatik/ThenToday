//
//  ScreenSnapshotTests.swift
//  ThenTodayTests
//
//  Created by Anton Solovev on 10.05.2026.
//

import SnapshotTesting
import XCTest

@testable import ThenToday

@MainActor
final class ScreenSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    func test_datePicker_light_iPhone13_portrait() {
        let vc = AppDependencies().makeDatePickerViewController()
        assertSnapshot(of: vc, as: .image(on: .iPhone13(.portrait), precision: 0.97), named: "date_picker_light")
    }

    func test_datePicker_dark_iPhone13_portrait() {
        let vc = AppDependencies().makeDatePickerViewController()
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13(.portrait), precision: 0.97, traits: dark),
            named: "date_picker_dark"
        )
    }

    func test_detail_light_iPhone13_portrait() {
        let image = UIImage(systemName: "globe.europe.africa.fill") ?? UIImage()
        let sut = DateInformationViewController(
            information: "Snapshot: sample historical note for this calendar date.",
            image: image,
            translateClient: UITestingStubTranslateClient()
        )
        sut.loadViewIfNeeded()
        let ready = expectation(description: "languages-loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            ready.fulfill()
        }
        wait(for: [ready], timeout: 2)
        sut.view.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image(on: .iPhone13(.portrait), precision: 0.97), named: "detail_light")
    }
}
