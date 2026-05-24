# Metric Sense (iOS)

Native Swift iPhone app for building an intuitive sense of metric ↔ imperial **environmental** temperatures (-15°F through 110°F). This is not a precision calculator — answers within about 2° count as correct.

## Temperature module

- **Round 1 (5 cards):** Freezing (0°C / 32°F), cool jacket weather (10°C / 50°F), very hot (38°C / 100°F), bitter cold (-26°C / -15°F), extreme heat (43°C / 110°F)
- **Round 2 (5 cards):** Common daily temperatures between those anchors
- **Round 3 (5 cards):** Neighbor temperatures that fill in the environmental range

Each card has two prompts:

1. **Celsius → Fahrenheit:** vertical thermometer slider across the full environmental Fahrenheit range
2. **Fahrenheit → Celsius:** multiple choice

### Learning rules

- A prompt must be answered correctly **3 times in a row** to be marked learned
- Missed prompts are weighted heavily for review
- Learned prompts from earlier rounds still appear occasionally in later rounds (low weight)
- When every prompt in a round is learned, a **quick tip interstitial** appears (placeholder copy for now) before the next round unlocks

Progress is stored locally with `UserDefaults` — no network required.

## Open in Xcode

1. Open `MetricSense/MetricSense.xcodeproj` in Xcode 15+ on macOS
2. Select the **MetricSense** scheme and an iPhone simulator (or device)
3. Set your **Development Team** in Signing & Capabilities
4. Run (⌘R)

Bundle ID: `com.papaacorn.metricsense`

## Project layout

```
MetricSense/
  MetricSense.xcodeproj
  MetricSense/
    Models/          # Temperature cards and progress types
    Services/        # Game engine and persistence
    ViewModels/      # Session state
    Views/           # SwiftUI screens
```

Future modules (distance, volume, etc.) can be added alongside this temperature trainer.
