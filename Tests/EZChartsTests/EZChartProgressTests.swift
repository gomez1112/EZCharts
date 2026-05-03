import Testing
@testable import EZCharts

@Test func clampedProgress() {
    #expect(EZChartProgress.clamped(-0.5) == 0)
    #expect(EZChartProgress.clamped(0.4) == 0.4)
    #expect(EZChartProgress.clamped(1.5) == 1)
}

@Test func scaledValueUsesClampedProgress() {
    #expect(EZChartProgress.scaled(100, progress: -1) == 0)
    #expect(EZChartProgress.scaled(100, progress: 0.25) == 25)
    #expect(EZChartProgress.scaled(100, progress: 2) == 100)
}

@Test func staggeredProgressStartsLaterForLaterItems() {
    let first = EZChartProgress.staggered(index: 0, count: 4, progress: 0.25)
    let last = EZChartProgress.staggered(index: 3, count: 4, progress: 0.25)

    #expect(first > last)
    #expect(EZChartProgress.staggered(index: 3, count: 4, progress: 1) == 1)
}

@Test func sequencedProgressRunsOneItemAtATimeByDefault() {
    let first = EZChartProgress.sequenced(index: 0, count: 3, progress: 0.4)
    let second = EZChartProgress.sequenced(index: 1, count: 3, progress: 0.4)
    let third = EZChartProgress.sequenced(index: 2, count: 3, progress: 0.4)

    #expect(first == 1)
    #expect(second > 0)
    #expect(second < 1)
    #expect(third == 0)
}

@Test func sequencedProgressCanOverlapItems() {
    let secondWithoutOverlap = EZChartProgress.sequenced(index: 1, count: 3, progress: 0.3)
    let secondWithOverlap = EZChartProgress.sequenced(index: 1, count: 3, progress: 0.3, overlap: 0.5)

    #expect(secondWithoutOverlap == 0)
    #expect(secondWithOverlap > 0)
}

@Test func zeroBasedDomainAddsHeadroomForPositiveValues() {
    let domain = EZChartDomain.zeroBased([20_000, 10_000, 50_000])

    #expect(domain.lowerBound == 0)
    #expect(domain.upperBound == 55_000)
}

@Test func zeroBasedDomainUsesFallbackForEmptyOrZeroValues() {
    #expect(EZChartDomain.zeroBased([Double]()) == 0...1)
    #expect(EZChartDomain.zeroBased([0, 0, 0]) == 0...1)
}

@Test func zeroBasedDomainIncludesNegativeValues() {
    let domain = EZChartDomain.zeroBased([-10.0, 20.0], headroom: 0.2)

    #expect(domain.lowerBound == -12)
    #expect(domain.upperBound == 24)
}
