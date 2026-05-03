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

@Test func sectorRangesNormalizePositiveValues() {
    let ranges = EZChartProgress.sectorRanges(for: [20.0, 30.0, 50.0])

    #expect(ranges.count == 3)
    #expect(ranges[0].lowerBound == 0)
    #expect(abs(ranges[0].upperBound - 0.2) < 0.0001)
    #expect(abs(ranges[1].lowerBound - 0.2) < 0.0001)
    #expect(abs(ranges[1].upperBound - 0.5) < 0.0001)
    #expect(abs(ranges[2].lowerBound - 0.5) < 0.0001)
    #expect(ranges[2].upperBound == 1)
}

@Test func sectorRangesIgnoreInvalidValuesWithoutChangingCount() {
    let ranges = EZChartProgress.sectorRanges(for: [20.0, -10.0, .nan, 30.0])

    #expect(ranges.count == 4)
    #expect(ranges[1].lowerBound == ranges[1].upperBound)
    #expect(ranges[2].lowerBound == ranges[2].upperBound)
    #expect(ranges[3].upperBound == 1)
}

@Test func revealedRangeUsesClampedProgress() {
    let range = 0.2..<0.7

    #expect(EZChartProgress.revealedRange(range, progress: -1).upperBound == 0.2)
    #expect(EZChartProgress.revealedRange(range, progress: 2).upperBound == 0.7)
    #expect(abs(EZChartProgress.revealedRange(range, progress: 0.5).upperBound - 0.45) < 0.0001)
}

@Test func animationProgressClampsAndEases() {
    let linear = EZChartAnimation(duration: 1, curve: .linear)
    let easeOut = EZChartAnimation(duration: 1, curve: .easeOut)

    #expect(linear.progress(at: -1) == 0)
    #expect(linear.progress(at: 0.25) == 0.25)
    #expect(linear.progress(at: 2) == 1)
    #expect(easeOut.progress(at: 0.5) > 0.5)
}
