
# SocketShare

![logo](./assets/ic_socketshare.png)

SocketShare is an Android application built with Flutter that allows you to send files to your PC even without internet connection. With SocketShare, you can send any type of file. 

*Note: The desktop app is under development and will be released soon.*

Key features

- Transfer files at flash speed.
- Send Large Files Without Limit.
- Free Connection and Data No cables, no internet, no data usage.
- Share all types of files without restrictions.

This app require specific permissions such as storage and camera.


## Installation

You need to have Flutter 3.19 installed

Clone the project

```bash
  git clone https://github.com/Vinesh-x00/flutter_socketshare.git
```

Go to the project directory

```bash
  cd flutter_socketshare
```

Install on android

Connect your Android device to your computer with a USB cable.

```bash
  flutter install --device-id <YOUR-DEVICE-ID>
```
Or install with apk

```bash
flutter build apk --release
```


## Tools used

- Flutter
- BLoC
- percent_indicator
- file_picker
- mobile_scanner 3.5.5
