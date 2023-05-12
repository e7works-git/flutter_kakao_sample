# [VChatCloud](https://vchatcloud.com) Flutter Sample App

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)  
![Languages](https://img.shields.io/badge/language-DART-informational)  
![Platform](https://img.shields.io/badge/platform-ANDROID-informational)
![Platform](https://img.shields.io/badge/IOS-informational)
![Platform](https://img.shields.io/badge/MAC-informational)
![Platform](https://img.shields.io/badge/WINDOW-informational)
![Platform](https://img.shields.io/badge/WEB-informational)

This sample demonstrates how you can use [VChatCloud Flutter SDK](https://github.com/e7works-git/flutter_sdk) in your own Flutter application. VChatCloud provides an easy-to-use Chat API, Chat SDKs, and a fully-managed chat platform on the backend that provides upload files, open graph, translation.

## Table of contents

- [VChatCloud Flutter Sample App](#vchatcloud-flutter-sample-app)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Requirements](#requirements)
  - [Getting started](#getting-started)
    - [Notice!](#notice)
  - [Getting Help](#getting-help)

## Introduction

This sample consists of several features, including:

- Connecting and disconnecting from VChatCloud server
- Join channel
- Send a message (text and file message)
- Receive channel events and handle appropriately

## Requirements

The minimum requirements for this demo are:

- Xcode or Android studio or Visual Studio Code
- Dart 2.13.0
- Flutter 2.0.0 or higher

## Getting started

This sample demonstrates a few example how you can use SDK on your application. The sample consists of the following:

- Connect and disconnect from VChatCloud Server
- Join channel
- Send / fetch a message (text and file message)
- Receive channel events and handle appropriately
- Update / Fetch user profile information (profile image / nickname)
- Get the last messages of a channel

### Notice!

To run this demo, create a chat room in VChatCloud's CMS, copy the ChannelKey of the chat room created in the dashboard, and paste it into the roomId value in `lib/main.dart`. You can then run the sample from the directory by typing flutter run in the command window.

```dart
// lib/main.dart
const roomId = "YOUR_CHANNEL_KEY"; // input your channel key from VChatCloud CMS
```

## Getting Help

Check out the Official VChatCloud [Flutter docs](https://vchatcloud.com/doc/flutter/chat/gettingStarted.html) tutorials.
