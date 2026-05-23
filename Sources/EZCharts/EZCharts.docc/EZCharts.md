# ``EZCharts``

Animate Swift Charts without replacing Swift Charts.

## Overview

EZCharts provides a small set of SwiftUI wrappers and progress helpers for common chart animation patterns:

- ``EZAnimatedChart`` wraps `Chart` and provides a progress value from `0` to `1`.
- ``EZAnimatedSectorChart`` wraps common `SectorMark` pie and donut charts with slice-by-slice sweep animation.
- ``EZChartProgress`` scales, sequences, staggers, and reveals values.
- ``EZChartDomain`` and `.ezChartYScale(for:)` keep animated bar-chart axes stable.

The package does not replace Swift Charts. You still write normal marks, axes, scales, and styles.

## Topics

### Animated 2D Charts

- ``EZAnimatedChart``
- ``EZChartAnimation``
- ``EZChartReveal``
- ``EZChartProgress``

### Sector Charts

- ``EZAnimatedSectorChart``
- ``EZSectorChartStyle``

### Stable Domains

- ``EZChartDomain``
