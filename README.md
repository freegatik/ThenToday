<img src="ThenToday/Resourses/Assets.xcassets/AppIcon.appiconset/180.png" width="200">

# ThenToday
![Static Badge](https://img.shields.io/badge/platform-iOS-white)
![Static Badge](https://img.shields.io/badge/lastet_release-v1.0.0-green)
![Static Badge](https://img.shields.io/badge/swift-v5.10-orange)

# 📖 About
## 👨‍💻 iOS Deployment Target: 16.0 
## 💻 Tech Stack
- Swift, UIKit, SnapKit; REST.
- `DayExplorationService`, `YandexTranslateClient`, wired in `AppDependencies`.
- Networking: `async`/`await`, `URLSession` + timeouts; work cancelled with `Task`.
- Errors: `CustomError` + string catalog. API keys only via env or local plist (see below).

## Requirements

- Xcode 15+ (Swift 5.9+)
- iOS 16.0+ deployment target

## Configuration (API keys)

Runtime keys for **Unsplash** and **Yandex Translate**:

| Variable | Description |
|----------|-------------|
| `UNSPLASH_ACCESS_KEY` | Unsplash API access key |
| `YANDEX_API_KEY` | Yandex Cloud Translate API key |

Set both under **Scheme → Run → Environment Variables**, or only locally in `ThenToday/Resourses/Info.plist` (do not commit real values).

## Build & tests

```bash
xcodebuild -scheme ThenToday -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -scheme ThenToday -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Adjust the simulator name to match `xcrun simctl list devices available`.

## CI

[`.github/workflows/ios.yml`](.github/workflows/ios.yml): `xcodebuild build test` on `iPhone 15` simulator (GitHub `macos-14` image).

## Lint (optional)

[SwiftLint](https://github.com/realm/SwiftLint): `swiftlint`

## 📱 Screenshots
⬜ Light Theme 
<h3 align="center"> Main Screen </h3>
<p align="center">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/LightTheme/1-ru.png.imageset/Снимок экрана 2024-08-17 в 17.22.29.png" width="200">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/LightTheme/1-en.png.imageset/Снимок экрана 2024-08-17 в 17.25.04.png" width="200">
</p>

<h3 align="center"> Information Screen </h3>
<p align="center">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/LightTheme/2.png.imageset/Снимок экрана 2024-08-17 в 17.25.35.png" width="200">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/LightTheme/3.png.imageset/Снимок экрана 2024-08-17 в 17.25.47.png" width="200">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/LightTheme/4.png.imageset/Снимок экрана 2024-08-17 в 17.27.24.png" width="200">
</p>

 ⬛ Dark Theme
<h3 align="center"> Main Screen </h3>
<p align="center">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/DarkTheme/1-ru.png.imageset/Снимок экрана 2024-08-17 в 17.23.16.png" width="200">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/DarkTheme/1-en.png.imageset/Снимок экрана 2024-08-17 в 17.24.03.png" width="200">
</p>

<h3 align="center"> Information Screen </h3>
<p align="center">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/DarkTheme/2.png.imageset/Снимок экрана 2024-08-17 в 17.26.17.png" width="200">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/DarkTheme/3.png.imageset/Снимок экрана 2024-08-17 в 17.26.34.png" width="200">
    <img src="ThenToday/Resourses/Assets.xcassets/screenshots/DarkTheme/4.png.imageset/Снимок экрана 2024-08-17 в 17.26.54.png" width="200">
</p>

## 🧑‍⚖️ License
```
MIT License

Copyright (c) 2025 Anton Solovev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
