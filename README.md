# LidSense

LidSense is a small native macOS app that reads and displays the current MacBook lid angle.

LidSense reads an undocumented HID feature report exposed by some Apple hardware, so its behavior should not be treated as a stable macOS API.

## Requirements

- macOS 26.4 or later, matching the current Xcode project deployment target
- Xcode with a macOS 26.4 SDK, or a newer compatible SDK
- A MacBook model that exposes the lid angle sensor through the HID report used by this app

The app may not work on every MacBook model or every macOS release.

## How It Works

`LidAngleReader.swift` uses IOKit HID APIs to look for an Apple HID device and read a feature report that appears to contain the lid angle. This sensor/report pairing is undocumented macOS behavior.

Because the behavior is undocumented, Apple may change or remove it at any time. Different MacBook models may expose different devices, report IDs, report formats, or no compatible lid angle data at all.

## Building

1. Open `LidSense.xcodeproj` in Xcode.
2. Select the `LidSense` target.
3. Build and run the app on a MacBook.

If the app cannot find or read the sensor, it will show an unavailable status message instead of an angle.

## License

LidSense is released under the MIT License. See `LICENSE` for details.
