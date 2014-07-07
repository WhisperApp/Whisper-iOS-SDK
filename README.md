# Whisper-iOS-SDK

[![CI Status](http://img.shields.io/travis/Yujin Ariza/Whisper-iOS-SDK.svg?style=flat)](https://travis-ci.org/Yujin Ariza/Whisper-iOS-SDK)
[![Version](https://img.shields.io/cocoapods/v/Whisper-iOS-SDK.svg?style=flat)](http://cocoadocs.org/docsets/Whisper-iOS-SDK)
[![License](https://img.shields.io/cocoapods/l/Whisper-iOS-SDK.svg?style=flat)](http://cocoadocs.org/docsets/Whisper-iOS-SDK)
[![Platform](https://img.shields.io/cocoapods/p/Whisper-iOS-SDK.svg?style=flat)](http://cocoadocs.org/docsets/Whisper-iOS-SDK)

The Whisper-iOS-SDK will let your users create Whisper content from inside your 
app with just a few lines of code. Currently, we support creating a Whisper
post from an Image, Data, file path, or URL, with a custom text overlay.

The SDK requires that the Whisper app is installed. If version 4.2 or higher of
the Whisper app is not installed, users will be prompted to the App Store to
download it. Our app only supports iOS 6.0 or higher.

## Requirements

## Installation

Whisper-iOS-SDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Whisper-iOS-SDK"

## Usage

### Manually Creating a Whisper

Manually creating a Whisper is done in two steps:

First, call either one of the configure methods. This defines the source of the
menu presentation, which can be either a `UIView`, or a `UIBarButtonItem`.

    [[WHPWhisperAppClient sharedClient] prepareWithView:view inRect:view.bounds];

Next, call one of the create methods to create the Whisper from any one of 
four data sources: `UIImage`, `NSData`, `NSString`, or `NSURL`.

    [[WHPWhisperAppClient sharedClient] createWhisperWithImage:image error:&error];

### Using a Whisper Button

Alternatively, you can use the standard Whisper button, and add it to your view:

    UIButton *whisperButton = [[WHPWhisperAppClient sharedClient] whisperButtonWithSize:kWHPWhisperAppClientButtonSize_Medium rounded:YES];
    [self.view addSubView:whisperButton];

When pressed, the button will retrieve the image data by calling protocol 
methods in the delegate property of the `WHPWhisperAppClient`. You can provide
these methods by setting the delegate property to one of your own classes:

    [WHPWhisperAppClient sharedClient].delegate = self;
    
    ...
    
    -(UIView *)whisperAppClientViewForMenuPresentation
    {
        return _view;
    }
    
    -(UIImage *)whisperAppClientSourceImageForWhisper
    {
        return _image;
    }
    
Note that your delegate class must conform to the protocol
`WHPWhisperAppClientDelegate`.

There is an example project that demonstrates the functionality described above,
and some additional properties. To run the example project, clone the repo, and
run `pod install` from the Example directory first.

## Author

Yujin Ariza, yujin@whisper.sh

## License

Whisper-iOS-SDK is available under the Apache license. See the LICENSE file for more info.

