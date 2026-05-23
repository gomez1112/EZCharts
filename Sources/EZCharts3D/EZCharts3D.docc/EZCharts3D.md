# ``EZCharts3D``

Animate Swift Charts `Chart3D` content with a dedicated 3D API.

## Overview

`EZCharts3D` is intentionally separate from `EZCharts`. Apps that only need 2D charts can depend on the base `EZCharts` product without compiling `Chart3D` symbols.

Use `EZAnimatedChart3D` with `EZChart3DProgress`:

```swift
import Charts
import EZCharts
import EZCharts3D
import SwiftUI

@available(iOS 26.0, macOS 26.0, *)
struct PipelineChart: View {
    var body: some View {
        EZAnimatedChart3D { progress in
            ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                let itemProgress = EZChart3DProgress.sequenced(
                    index: index,
                    count: points.count,
                    progress: progress
                )

                PointMark(
                    x: .value("X", point.x),
                    y: .value("Y", EZChart3DProgress.scaled(point.y, progress: itemProgress)),
                    z: .value("Z", point.z)
                )
            }
        }
    }
}
```

## Topics

### Animated 3D Charts

- ``EZAnimatedChart3D``
- ``EZChart3DProgress``
