# baby_names

A new Firebase for Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Notes

- https://github.com/flutter/flutter/issues/22136
- https://stackoverflow.com/questions/54019347/flutter-using-cloud-firestore-giving-errors-on-ios-simulator

Need to enter command belows before building iOS application:

```
$ flutter clean
$ cd ios
$ pod update Firebase/Firestore
$ cd ..
$ flutter run -v -d "iPhone Xʀ"
```
