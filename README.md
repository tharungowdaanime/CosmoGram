# CosmoGram 🚀

A application where you get beautiful images of the Universe.

---
<img width="665" height="1412" alt="birthday_1" src="https://github.com/user-attachments/assets/940cc30f-f324-421a-b15f-ea0e8605ca1a" />

## Try it out
**[Try CosmoGram](https://github.com/tharungowdaanime/CosmoGram/releases/download/v1.0.0/app-armeabi-v7a-release.apk)**

## 📲 Download & Installation (Android)

Because Android devices use different processor types, the production release has been optimized and split into lightweight installer packages under the 25MB threshold. Download the version that matches your device directly from the file list above:

* **`app-arm64-v8a-release.apk`** — Best for modern 64-bit Android smartphones.
* **`app-armeabi-v7a-release.apk`** — Best for budget or older 32-bit Android devices.

*Steps to install:*
1. Download the correct `.apk` file to your device.
2. Tap the file to install it. If prompted by Android security, toggle **"Allow from this source"** in your settings to authorize the installation.
3. Launch **CosmoGram** from your app drawer!

---

## Features

* **🌌 Daily Discovery Feed:** Uses NASA's API to get planetary imagery and structured deep-space documentation.
* **🎂 Cosmic Birthday Lookup:** Users can type their exact birth date coordinate (`YYYY-MM-DD`) to get what NASA's satellite captured on that day.
* **📥 Local Asset Downloader:** If users like the image then they can directly download the images into their galleries as clean `.jpg` files.


---
## Credits

* **Frontend Framework:** Flutter & Dart (Built entirely inside a streamlined `Screen.dart` architecture for fast personal iteration).
* **UI Prototyping:** **Stitch** (Used to rapidly wireframe the visual layout elements of the main dashboards).
* **Code Companion:** **Gemini** (Utilized to convert exported Stitch XML interface templates into functional Flutter boilerplate and troubleshoot async `Future` API calls).
* **Branding:** **Gemini Image Generation** (Gemini Nano was used to generate the app icon).



## ⚙️ How to Run Locally

If you want to clone this repository and build the code directly inside your own development environment:

### Prerequisites
* Flutter SDK (Targeting Channel stable)
* Dart SDK
* An Android Emulator or physical device with Developer Options enabled

### Environment Configuration
To prevent public exposure of sensitive developer keys on GitHub, the main network file contains a placeholder configuration. Open `lib/Screen.dart` and insert your own official NASA API credential string:

```dart
String nasaApiKey = "PASTE_YOUR_NASA_API_KEY_HERE"; 
