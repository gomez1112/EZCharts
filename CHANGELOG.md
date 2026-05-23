# Changelog

All notable changes to EZCharts are documented here.

## 0.2.3 - 2026-05-23

- Split `Chart3D` support into a separate `EZCharts3D` product so the base `EZCharts` product remains focused on 2D Swift Charts.
- Added compiler gating around `Chart3D` source so older toolchains can still consume the base product.
- Added Reduce Motion handling for animated chart progress.
- Replaced wall-clock animation timing with `ContinuousClock`.
- Added explicit sector identity support with `id:` overloads.
- Added generic sector foreground styling so callers can use any `ShapeStyle`, including colors and gradients.
- Added `legendVisibility` to `EZSectorChartStyle`.
- Added DocC documentation, GitHub Actions CI, Swift Package Index configuration, and MIT license metadata.

## 0.1.3

- Added progressive 2D chart APIs, simplified sector chart animation, and Chart3D animation support.
- Added detailed README usage examples.
- Added Swift Testing coverage for progress helpers, stable chart domains, and sector range helpers.

## 0.1.0

- Initial EZCharts package scaffold.
- Added animated 2D chart progress helpers and demo app.
