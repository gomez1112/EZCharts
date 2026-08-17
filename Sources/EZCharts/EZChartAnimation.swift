import SwiftUI

/// Timing configuration used by animated charts.
public struct EZChartAnimation: Equatable, Sendable {
    /// A SwiftUI animation curve selection that can gain new static members without breaking exhaustive switches.
    public struct Curve: Equatable, Sendable {
        package enum Kind: Equatable, Sendable {
            case easeInOut
            case easeOut
            case linear
            case spring(duration: Double, bounce: Double)
        }

        package let kind: Kind

        private init(_ kind: Kind) { self.kind = kind }

        public static let easeInOut = Curve(.easeInOut)
        public static let easeOut = Curve(.easeOut)
        public static let linear = Curve(.linear)

        /// Creates a perceptual-duration spring with the specified bounce.
        public static func spring(duration: Double, bounce: Double) -> Curve {
            Curve(.spring(duration: duration, bounce: bounce))
        }

        @available(*, deprecated, renamed: "spring(duration:bounce:)")
        public static func spring(response: Double, dampingFraction: Double) -> Curve {
            .spring(duration: response, bounce: 1 - dampingFraction)
        }
    }

    public var duration: TimeInterval
    public var delay: TimeInterval
    public var curve: Curve

    public init(duration: TimeInterval = 0.8, delay: TimeInterval = 0, curve: Curve = .easeOut) {
        self.duration = duration
        self.delay = delay
        self.curve = curve
    }

    public static let smooth = EZChartAnimation(duration: 0.9, curve: .easeInOut)
    public static let quick = EZChartAnimation(duration: 0.45, curve: .easeOut)
    public static let snappy = EZChartAnimation(duration: 0.7, curve: .spring(duration: 0.55, bounce: 0.15))

    package var swiftUIAnimation: Animation {
        let baseAnimation = switch curve.kind {
        case .easeInOut: Animation.easeInOut(duration: max(duration, 0))
        case .easeOut: Animation.easeOut(duration: max(duration, 0))
        case .linear: Animation.linear(duration: max(duration, 0))
        case let .spring(springDuration, bounce):
            Animation.spring(duration: max(springDuration, 0), bounce: bounce)
        }
        return baseAnimation.delay(max(delay, 0))
    }

    @available(*, deprecated, message: "SwiftUI interpolation is now the source of truth; use EZChartProgress.clamped(_:) for progress math.")
    public func progress(at rawProgress: Double) -> Double { EZChartProgress.clamped(rawProgress) }
}

/// A rendering-only reveal effect for an animated chart.
public struct EZChartReveal: Equatable, Sendable {
    package enum Kind: Equatable, Sendable { case none, horizontal, vertical, radial }
    package let kind: Kind
    private init(_ kind: Kind) { self.kind = kind }

    public static let none = EZChartReveal(.none)
    public static let horizontal = EZChartReveal(.horizontal)
    public static let vertical = EZChartReveal(.vertical)
    public static let radial = EZChartReveal(.radial)
}
