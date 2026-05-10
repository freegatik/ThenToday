//
//  LayoutPerformanceTests.swift
//  ThenTodayTests
//
//  Created by Anton Solovev on 10.05.2026.
//

import XCTest

@testable import ThenToday

final class LayoutPerformanceTests: XCTestCase {
    @MainActor
    func test_datePicker_loadAndLayout_performance() {
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            let vc = AppDependencies().makeDatePickerViewController()
            vc.loadViewIfNeeded()
            vc.view.setNeedsLayout()
            vc.view.layoutIfNeeded()
        }
    }
}
