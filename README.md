# Welcome to the ADB_Connector_Mac!
This repository contains a remake of the [ADB Connector]. It is written in
Swift and is more flexible in the way it manages the Android devices. As it is
using SwiftUI, it requires macOS 10.14 or higher.

## Idea
The initial idea was to create a proper application to automatically connect to
Android devices using the *Android Debug Bridge*. It should be capable to
manage multiple Android devices at a time.

## Approach
The approach of this project is similiar to the [ADB Connector]. At first, the
user has to plug his device to a USB port of the Mac. After that, the app opens
a port on the Android device using the ``adb``. Once the user has unplugged his
device, a network connection to the ``adb`` is established.

### GUI-Design
The graphicial user interface consists of a list with the registered devices.
The detailed view for each device is a SwiftUI view that is connected to an
object representation of that device.

### Final notes
As Android Studio has these days such a feature built in, this project will not
be developed any further.

© 2019 [mhahnFr](https://www.github.com/mhahnFr)
