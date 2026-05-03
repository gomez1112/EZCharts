import XCTest
@testable import EZCharts

final class EZChartProgressTests: XCTestCase {
    func testClampedProgress() {
        XCTAssertEqual(EZChartProgress.clamped(-0.5), 0)
        XCTAssertEqual(EZChartProgress.clamped(0.4), 0.4)
        XCTAssertEqual(EZChartProgress.clamped(1.5), 1)
    }

    func testScaledValueUsesClampedProgress() {
        XCTAssertEqual(EZChartProgress.scaled(100, progress: -1), 0)
        XCTAssertEqual(EZChartProgress.scaled(100, progress: 0.25), 25)
        XCTAssertEqual(EZChartProgress.scaled(100, progress: 2), 100)
    }

    func testStaggeredProgressStartsLaterForLaterItems() {
        let first = EZChartProgress.staggered(index: 0, count: 4, progress: 0.25)
        let last = EZChartProgress.staggered(index: 3, count: 4, progress: 0.25)

        XCTAssertGreaterThan(first, last)
        XCTAssertEqual(EZChartProgress.staggered(index: 3, count: 4, progress: 1), 1)
    }
}
