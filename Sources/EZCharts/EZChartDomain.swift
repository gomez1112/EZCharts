import Charts
import SwiftUI

public enum EZChartDomain {
    public static func zeroBased<Values: Sequence>(
        _ values: Values,
        headroom: Double = 0.1,
        fallback: ClosedRange<Double> = 0...1
    ) -> ClosedRange<Double> where Values.Element: BinaryFloatingPoint {
        makeZeroBasedDomain(
            values.map(Double.init),
            headroom: headroom,
            fallback: fallback
        )
    }

    public static func zeroBased<Values: Sequence>(
        _ values: Values,
        headroom: Double = 0.1,
        fallback: ClosedRange<Double> = 0...1
    ) -> ClosedRange<Double> where Values.Element: BinaryInteger {
        makeZeroBasedDomain(
            values.map(Double.init),
            headroom: headroom,
            fallback: fallback
        )
    }

    private static func makeZeroBasedDomain<Values: Sequence>(
        _ values: Values,
        headroom: Double,
        fallback: ClosedRange<Double>
    ) -> ClosedRange<Double> where Values.Element == Double {
        let finiteValues = values.filter(\.isFinite)

        guard let minimum = finiteValues.min(), let maximum = finiteValues.max() else {
            return normalized(fallback)
        }

        guard minimum != 0 || maximum != 0 else {
            return normalized(fallback)
        }

        let boundedHeadroom = max(headroom, 0)
        var lowerBound = min(0, minimum)
        var upperBound = max(0, maximum)

        if lowerBound < 0 {
            lowerBound += lowerBound * boundedHeadroom
        }

        if upperBound > 0 {
            upperBound += upperBound * boundedHeadroom
        }

        guard lowerBound < upperBound else {
            return normalized(fallback)
        }

        return lowerBound...upperBound
    }

    private static func normalized(_ range: ClosedRange<Double>) -> ClosedRange<Double> {
        guard range.lowerBound.isFinite, range.upperBound.isFinite, range.lowerBound < range.upperBound else {
            return 0...1
        }

        return range
    }
}

@available(iOS 16.0, macOS 13.0, *)
public extension View {
    func ezChartYScale<Values: Sequence>(
        for values: Values,
        headroom: Double = 0.1,
        fallback: ClosedRange<Double> = 0...1
    ) -> some View where Values.Element: BinaryFloatingPoint {
        chartYScale(domain: EZChartDomain.zeroBased(values, headroom: headroom, fallback: fallback))
    }

    func ezChartYScale<Values: Sequence>(
        for values: Values,
        headroom: Double = 0.1,
        fallback: ClosedRange<Double> = 0...1
    ) -> some View where Values.Element: BinaryInteger {
        chartYScale(domain: EZChartDomain.zeroBased(values, headroom: headroom, fallback: fallback))
    }
}
