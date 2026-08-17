import Charts
import SwiftUI

public enum EZChartDomain {
    public static func zeroBased<Values: Sequence>(
        _ values: Values,
        headroom: Double = 0.1,
        fallback: ClosedRange<Double> = 0...1
    ) -> ClosedRange<Double> where Values.Element: EZChartValue {
        let finiteValues = values.map(\.ezChartValue).filter(\.isFinite)
        guard let minimum = finiteValues.min(), let maximum = finiteValues.max() else {
            return normalized(fallback)
        }
        guard minimum != 0 || maximum != 0 else { return normalized(fallback) }

        let boundedHeadroom = max(headroom, 0)
        let lowerBase = min(0, minimum)
        let upperBase = max(0, maximum)
        let lowerBound = lowerBase < 0 ? lowerBase * (1 + boundedHeadroom) : lowerBase
        let upperBound = upperBase > 0 ? upperBase * (1 + boundedHeadroom) : upperBase
        guard lowerBound.isFinite, upperBound.isFinite, lowerBound < upperBound else {
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

public extension View {
    func ezChartYScale<Values: Sequence>(
        for values: Values,
        headroom: Double = 0.1,
        fallback: ClosedRange<Double> = 0...1
    ) -> some View where Values.Element: EZChartValue {
        chartYScale(domain: EZChartDomain.zeroBased(values, headroom: headroom, fallback: fallback))
    }
}
