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

    /// Solid bitmap — avoids SF Symbol raster differences across iOS minor versions on CI.
    private func snapshotPlaceholderImage() -> UIImage {
        let size = CGSize(width: 120, height: 120)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemBlue.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    func test_datePicker_light_iPhone13_portrait() {
        let vc = AppDependencies().makeDatePickerViewController()
        let light = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(
            of: vc,
            as: .image(
                on: .iPhone13(.portrait),
                precision: 0.94,
                perceptualPrecision: 0.97,
                traits: light
            ),
            named: "date_picker_light"
        )
    }

    func test_datePicker_dark_iPhone13_portrait() {
        let vc = AppDependencies().makeDatePickerViewController()
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(
            of: vc,
            as: .image(
                on: .iPhone13(.portrait),
                precision: 0.94,
                perceptualPrecision: 0.97,
                traits: dark
            ),
            named: "date_picker_dark"
        )
    }

    func test_detail_light_iPhone13_portrait() {
        let sut = DateInformationViewController(
            information: "Snapshot: sample historical note for this calendar date.",
            image: snapshotPlaceholderImage(),
            translateClient: UITestingStubTranslateClient()
        )
        sut.loadViewIfNeeded()
        let ready = expectation(description: "languages-loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            ready.fulfill()
        }
        wait(for: [ready], timeout: 2)
        sut.view.layoutIfNeeded()
        let light = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(
            of: sut,
            as: .image(
                on: .iPhone13(.portrait),
                precision: 0.94,
                perceptualPrecision: 0.97,
                traits: light
            ),
            named: "detail_light"
        )
    }
}
