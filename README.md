# Metric Sense

An offline-first learning app that helps people switching from imperial to metric build quick, intuitive equivalencies — starting with everyday **environmental temperatures** (-15°F through 110°F).

## iOS (Swift) — recommended

The native iPhone app lives in [`MetricSense/`](MetricSense/README.md).

- SwiftUI, iOS 17+
- Vertical thermometer slider for Celsius → Fahrenheit
- Multiple choice for Fahrenheit → Celsius
- Five-card rounds, 3-in-a-row mastery, spaced review of misses
- Placeholder quick tips between rounds

Open `MetricSense/MetricSense.xcodeproj` in Xcode on a Mac to build and run.

## React Native prototype (legacy)

The repository root still contains an earlier Expo/React Native prototype (`App.tsx`). New feature work targets the Swift iOS app in `MetricSense/`.

```sh
npm install
npm start
```
