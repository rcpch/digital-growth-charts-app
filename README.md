# Digital Growth Charts App

This is a flutter wrapper for the RCPCH digital growth charts. 

![rcpch logo](./assets/images/pixelated_rcpch_incubator_alpha.png)

## Getting Started

The RCPCH Digital Growth Charts App is a Flutter 3 project, written in Dart 3.7. Flutter is a mobile application development framework which allows us to develop in a single codebase and from this deploy native apps for iOS, Android, web and desktop.

## Local development setup

1. Download flutter and Dart with dependencies (iOS and Android SDKs) [here](https://docs.flutter.dev/get-started/install). You will need to create a virtual device to demo the app on, or connect a real device.

1. Clone this repository

```shell
git clone https://github.com/rcpch/digital-growth-charts-app/tree/main
```

```shell
cd digital-growth-charts-app
```

1. Install dependencies

```shell
dart pub get
```

2. Create a `.env` file. The app consumes the RCPCH Growth API so you will need a key from `https://growth.rcpch.ac.uk/integrator/making-api-calls/`. Save a `.env` file in the root of your project with the following variables:

```shell
DGC_BASE_URL=https://api.rcpch.ac.uk/growth/v1
DGC_API_KEY=********* //your key here **DO NOT COMMIT THIS TO VERSION CONTROL**
```

3. Run the application (web browser)

```shell
flutter run
```

1. Run the application (Android emulator)

```shell
flutter emulators
1 available emulator:

Id                  • Name                • Manufacturer • Platform

Medium_Phone_API_36 • Medium Phone API 36 • Generic      • android

To run an emulator, run 'flutter emulators --launch <emulator id>'.
To create a new emulator, run 'flutter emulators --create [--name xyz]'.

You can find more information on managing emulators at the links below:
  https://developer.android.com/studio/run/managing-avds
  https://developer.android.com/studio/command-line/avdmanager

flutter emulators --launch Medium_Phone_API_36
```

You must wait until the emulator has booted up and is showing you the Android home screen.

```shell
flutter run
```

The first time you do this it will download all software build tools ever created so expect it to take ages.

The app has been tested on:

- iOS (@eatyourpeas)
- Android (@pacharanero)
- Linux Desktop (@pacharanero)


## Some installation notes

- If your Dart SDK isn't the correct version (at the time of writing it needs to be >3) then you can run `flutter upgrade` to update both Flutter and Dart. For some reason this was even required on a new install of Flutter in one case.

- The Android Virtual Device Manager defaults to a very low amount of disk space for virtual Android devices, and quite often this disk space is insufficient to actually load an app into, causing failure of the app to run. There will be a 'not enough disk space' or similar error. To increase disk space, you can Edit the Virtual Device in Android Studio, select 'Advanced' and increase the device disk storage to something bigger.


## Troubleshooting

```
The Android emulator exited with code 1 during startup
Android emulator stderr:
Address these issues and try again.
```

Try cold booting the Emulator. Go to the Android Virtual Device Manager in Android Studio and select "Cold Boot".