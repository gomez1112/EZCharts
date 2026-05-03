import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
public struct EZChartAnimation: Equatable {
    public enum Curve: Equatable {
        case easeInOut
        case easeOut
        case linear
        case spring(response: Double, dampingFraction: Double)
    }

    public var duration: TimeInterval
    public var delay: TimeInterval
    public var curve: Curve

    public init(
        duration: TimeInterval = 0.8,
        delay: TimeInterval = 0,
        curve: Curve = .easeOut
    ) {
        self.duration = duration
        self.delay = delay
        self.curve = curve
    }

    public static let smooth = EZChartAnimation(duration: 0.9, curve: .easeInOut)
    public static let quick = EZChartAnimation(duration: 0.45, curve: .easeOut)
    public static let snappy = EZChartAnimation(
        duration: 0.7,
        curve: .spring(response: 0.55, dampingFraction: 0.85)
    )

    var swiftUIAnimation: Animation {
        switch curve {
        case .easeInOut:
            return .easeInOut(duration: duration)
        case .easeOut:
            return .easeOut(duration: duration)
        case .linear:
            return .linear(duration: duration)
        case let .spring(response, dampingFraction):
            return .spring(
                response: response,
                dampingFraction: dampingFraction
            )
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
public enum EZChartReveal: Equatable {
    case none
    case horizontal
}
