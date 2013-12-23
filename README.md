## INDANCSClient
#### Objective-C Apple Notification Center Service Implementation

### Overview

This is an Objective-C client and server implementation of the [Apple Notification Center Service](https://developer.apple.com/library/IOS/documentation/CoreBluetooth/Reference/AppleNotificationCenterServiceSpecification/Introduction/Introduction.html) (ANCS) specification. This allows Bluetooth LE devices to connect to an iOS device running iOS 7 or later and receive all push/local notifications.

This project contains two main parts: 

1. **`INDANCSServer`** *(iOS 7+)* - a small component that runs on an iOS device to expose the ANCS service and some device information (name, model). 
2. **`INDANCSClient`** *(OS X 10.9+)* - a Mac framework that has a simple block based API for scanning and registering for notifications from iOS devices that are running the `INDANCSServer` code.

I made this because it was a great way to learn the ins and outs of Core Bluetooth and because the idea of wirelessly receiving notifications from an iOS device is way cool.

**WARNING: This is alpha quality code and hasn't been tested in production. Also, unit tests are yet to be implemented.**

### Requirements

* iPhone 4S or better running iOS 7 or higher. Previous iPhone models (including iPhone 4) do not support Bluetooth 4.0.
* A Mac with Bluetooth 4.0 support running OS X 10.9 or higher. Macs made after mid-2011 support Bluetooth 4.0 (starting with the mid-2011 MacBook Air). See [this page](http://www.everymac.com/systems/by_capability/macs-with-bluetooth-different-bluetooth-capabilities.html) for more info.

### Getting Started

The easiest way to try out this project is to simply compile and run the `INDANCSiPhone` and `INDANCSMac` example projects on your iOS device and Mac, respectively. 

If both devices have Bluetooth turned on, you should see a notification from the Mac app indicating that it has found your iOS device and from this point, any notification from the iOS device should appear in the Mac app's table view. Use the "Post Test Notification" button in the iOS app to try it instantly.

The sections below go into more detail on how to configure `INDANCSServer` and `INDANCSClient` in your own project.

### INDANCSServer

While the ANCS service exists on all iOS 7+ devices, it requires additional code to expose the service to outside peripherals. With `INDANCSServer`, this only takes a couple lines of code.

Link against `CoreBluetooth.framework` and start advertising:

```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.server = [[INDANCSServer alloc] initWithUID:@"INDANCSServer"];
	[self.server startAdvertising];
    return YES;
}
```

The UID parameter allows you to specify a restoration identifier for use with iOS 7's [Bluetooth State Preservation/Restoration](https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html) features. 

If you want to advertise the ANCS service while the app is in the background, you also need to [add the `bluetooth-peripheral` background mode to your Info.plist file](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/plist/info/UIBackgroundModes).

### INDANCSClient

`INANCSClient` is distributed as a Mac framework.

#### Scanning

`INDANCSClient` provides a simple block-based API for scanning for iOS devices that are running `INDANCSServer`:

```obj-c
#import <INDANCSClient/INDANCSClientFramework.h>

self.client = [[INDANCSClient alloc] init];
[self.client scanForDevices:^(INDANCSClient *client, INDANCSDevice *device) {
	NSLog(@"Found device: %@", device.name);
}];
```

#### Registering for Notifications

At the point where a device is found by `-scanForDevices:`, `INDANCSClient` has already connected to the device (necessary in order to retrieve device information). It will remain connected for a period of time that can be set using the `registrationTimeout` property. It is best to register for notifications within this window so that `INDANCSClient` doesn't need to reconnect to the device.

Notification registration also uses a simple block-based API:

```obj-c
[client registerForNotificationsFromDevice:device withBlock:^(INDANCSClient *c, INDANCSNotification *n) {
	NSLog(@"Notification: %@ - %@", n.title, n.message);
}];
```

The `INDANCSNotification` object has all the information about the notification, including the device & application that it came from. Of particular importance is the `latestEventID` property, which tells you whether the notification was created, modified, or removed.

#### Connection State

The `INDANCSClientDelegate` protocol documented in `INDANCSClient.h` has methods that inform the delegate about the connection state (e.g. when a device disconnects or fails to connect).

Since Bluetooth connections can often be unreliable, `INDANCSClient` includes support for automatically attempting reconnection when a device disconnects through the `attemptsAutomaticReconnection` property, which is set to `YES` by default.

#### Caching

`INDANCSClient` implements an on-disk and in-memory cache of app attributes, as recommended by Apple's guidelines to avoid wasting energy by requesting app information over Bluetooth every time a notification is received.

The `INDANCSKeyValueStore` protocol describes the interface that you can use to implement your custom key-value store for use with `INDANCSClient`. Two existing implementations are provided with the framework:

* **`INDANCSInMemoryStore`** - An in-memory key-value store backed by an `NSDictionary`.
* **`INDANCSObjectiveKVDBStore`** - A persistent key-value store backed by [ObjectiveKVDB](https://github.com/indragiek/ObjectiveKVDB).

Calling `-init` on `INDANCSClient` automatically initializes it using an instance of `INDANCSObjectiveKVDBStore` for persistent app metadata storage. If you want to use a different key-value store (or configure store file names, locations, etc.) you can use the `initWithMetadataStore:` initializer to pass in an object conforming to the `INDANCSKeyValueStore` protocol.

### Contact

* Indragie Karunaratne
* [@indragie](http://twitter.com/indragie)
* [http://indragie.com](http://indragie.com)

### License

`INDANCSClient` is licensed under the MIT License.
