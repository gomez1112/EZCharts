# Platform Differences

EZCharts supports iOS 17, macOS 14, watchOS 10, and visionOS 1 or later.

## Reveal masks on watchOS

Swift Charts does not make `chartPlotStyle(content:)` available on watchOS. On iOS, macOS, and visionOS, a horizontal reveal therefore masks only the plot and leaves axes and legends visible. On watchOS, EZCharts applies the same rendering mask to the complete chart as a fallback, so axis labels and the legend are also clipped until the animation completes. This works best with the minimal or hidden axes commonly used on compact watch displays.

The mask changes rendering without hiding chart marks from the accessibility tree.

## Chart3D

The `EZCharts3D` product builds as an empty module on watchOS. `EZAnimatedChart3D` is available only where Swift Charts provides `Chart3D` (iOS 26, macOS 26, and visionOS 26 or later).
