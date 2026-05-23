# Metric Sense

An offline-first React Native learning app for Android, iPhone, and iPad that builds quick intuition between metric and imperial measurements.

The first module is a temperature trainer for everyday environmental temperatures from freezing through about 100F. It starts with anchor points, adds more temperatures as the user learns, and keeps missed prompts in heavier rotation.

## Mobile targets

Metric Sense is configured as a mobile app for:

- Android phones and tablets via package `com.papaacorn.metricsense`
- iPhone via bundle identifier `com.papaacorn.metricsense`
- iPad, with tablet support enabled

## Run locally

```sh
npm install
npm start
```

Use `npm run android` or `npm run ios` to open the app in an emulator, simulator, or connected device. The app is built with Expo and stores practice progress locally on the device.
