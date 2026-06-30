# CosmoGram 🚀

A sleek, dark-themed mobile application built with Flutter that interfaces directly with NASA's core telemetry servers to stream live deep-space imagery, astronomy archives, and real-time cosmic metrics.

---

## 📲 Download & Installation (Android)

Because Android devices use different processor types, the production release has been optimized and split into lightweight installer packages under the 25MB threshold. Download the version that matches your device directly from the file list above:

* **`app-arm64-v8a-release.apk`** — Best for modern 64-bit Android smartphones.
* **`app-armeabi-v7a-release.apk`** — Best for budget or older 32-bit Android devices.

*Steps to install:*
1. Download the correct `.apk` file to your device.
2. Tap the file to install it. If prompted by Android security, toggle **"Allow from this source"** in your settings to authorize the installation.
3. Launch **CosmoGram** from your app drawer!

---

## ✨ Features

* **🌌 Daily Discovery Feed:** Handshakes with NASA's APOD (Astronomy Picture of the Day) API to fetch real-time planetary imagery, capturing telemetry dates, and structured deep-space documentation.
* **🎂 Cosmic Birthday Lookup:** Users can type their exact birth date coordinate (`YYYY-MM-DD`) to query what NASA's satellite sensors captured on that day.
* **📥 Local Asset Downloader:** If users like the image then they can directly download the images into their galleries as clean `.jpg` files.
* **📊 Telemetry Vector Dashboard:** It also displays mock deep-space stats like constellation boundaries, star distances, and an active cosmic radiation mapping bar.

---

## 🛠️ The Tech Stack & AI Toolkit

* **Frontend Framework:** Flutter & Dart (Built entirely inside a streamlined `Screen.dart` architecture for fast personal iteration).
* **UI Prototyping:** **Stitch** (Used to rapidly wireframe the visual layout elements of the main dashboards).
* **Code Companion:** **Gemini** (Utilized to convert exported Stitch XML interface templates into functional Flutter boilerplate and troubleshoot async `Future` API calls).
* **Branding:** **Gemini Image Generation** (Gemini Nano was used to generate the app icon).

