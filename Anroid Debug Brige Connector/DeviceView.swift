//
//  DeviceView.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 26.11.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import SwiftUI

struct DeviceView: View {
    /// The Android device associated with this view.
    @ObservedObject
    var device: Device
    
    /*var body: some View {
        VStack {
            Text(device.deviceName)
                .bold()
            
            if device.connectionType == .USB {
                Text("Verbindung: USB")
            } else if device.connectionType == .LAN {
                Text("Verbindung: (W)LAN")
            } else {
                Text("Nicht verbunden")
            }
            showUserMessage()
            HStack {
                Button(action: {
                    self.device.startConnecting()
                }) {
                    Text(device.buttonText)
                }
                if device.lastConnectingAction != .connectWLAN && device.lastConnectingAction != .checkWLANConnection && device.lastConnectingAction != nil {
                    Button(action: {
                        self.device.skipUSBConnection()
                    }) {
                        Text(">>")
                    }
                }
            }
        }
    }*/
    var body: some View {
        NavigationLink(destination: Text(device.deviceName)) {
            
        }
    }
    
    /// Returns a manipulated text containing the user information of the device shown by this view.
    ///
    /// - Returns: A Text instance manipulated to appropriatly display the user information.
    private func showUserMessage() -> Text {
        let toReturn = Text(device.userMessage)
        switch device.mode {
        case .error:
            return toReturn.foregroundColor(.red)
        case .success:
            return toReturn.foregroundColor(.green)
        case .warning:
            return toReturn.foregroundColor(.yellow)
        case .no_flag:
            return toReturn

        }
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(device: Device("Androidgerät"))
    }
}
