# GitHub Repository List

A Flutter app for searching public GitHub repositories, viewing their details, and saving them as favorites locally.

## Features

- GitHub repository search using keywords, with infinite scrolling (page size of 30).
- Repository details, with subscriber count.
- Synchronized favorites across all screens.
- Favorites saved locally using `shared_preferences`.

## Development environment

- Flutter 3.47.7
- Dart 3.13.5

> Android release builds were verified with JDK 21 and Gradle 9.3.1.

## Run

Connect a device or start an emulator, then run:

```bash
flutter pub get
flutter run
```

## Build

Android release APK:

```bash
flutter build apk --release
```

iOS release build requires macOS, Xcode and a signing configuration:

```bash
flutter build ios --release
```

## Checks

```bash
flutter analyze
flutter test
```

## Implementation notes

- Features are organized into repositories and favorites, with data and
  presentation code kept together within each feature.
- Riverpod provides dependencies and shares application state.
- Favorites update immediately, with rollback if saving fails.
- Favorites store only the repository ID, full name, and avatar URL.
- Search ignores outdated responses when a newer search has started.
- HTTP access and local storage can be replaced with fakes in tests.

> `shared_preferences_android` 2.5.1 has a [known issue with release builds](https://github.com/flutter/flutter/issues/194649). As a workaround, the suggested ProGuard rules were added to `android/app/proguard-rules.pro`.

## API usage

The app uses GitHub’s public REST API without authentication:

- `GET /search/repositories` with `q`, `page`, and `per_page=30`.
- `GET /repos/{owner}/{repo}` for repository details, including
  `subscribers_count`.

Search pagination stops at GitHub’s 1,000-result limit. Rate-limit
responses show a specific message asking the user to wait before retrying.

Favorites are stored locally.

## Validation

- Physical device:
  - Huawei P10 lite running Android 8
  - iPhone 16e running iOS 26.3
  - Google Pixel 4 running Android 13
- Manual checks passed: search, pagination, repository details, favorites synchronization, persistence after app restart, and retries.
- Automated tests: 5 tests passed (2 unit tests, 3 widget tests).
- Rate-limit messages displayed correctly in Search, pagination, and Details.