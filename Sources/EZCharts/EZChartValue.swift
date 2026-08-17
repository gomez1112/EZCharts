import CoreGraphics

/// A numeric value that EZCharts can convert to chart coordinates.
public protocol EZChartValue {
    /// The value represented as a `Double` for Swift Charts.
    var ezChartValue: Double { get }
}

extension Double: EZChartValue { public var ezChartValue: Double { self } }
extension Float: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension CGFloat: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension Int: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension Int8: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension Int16: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension Int32: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension Int64: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension UInt: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension UInt8: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension UInt16: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension UInt32: EZChartValue { public var ezChartValue: Double { Double(self) } }
extension UInt64: EZChartValue { public var ezChartValue: Double { Double(self) } }
