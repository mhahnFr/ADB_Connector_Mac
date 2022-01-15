//
//  MainView.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 14.10.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import SwiftUI

struct MainView: View {
    /// The reference to the settings, which has the list of the devices.
    @ObservedObject
    var settings = Settings.shared
    /// The state of the view, which device has to be shown.
    @State
    var selectedDevice = 0
    /// A reference to the NSApplicationDelegate for convience.
    let appDelegate = (NSApp.delegate as? AppDelegate)
    
    /*var body: some View {
        HStack {
            VStack {
                List(settings.devices) { device in
                    Button(action: { self.selectedDevice = self.settings.devices.firstIndex(of: device)! }) {
                        Text(device.deviceName)
                    }
                }
                Button(action: { self.appDelegate?.addDevice() }) {
                    Text("Hinzufügen...")
                }
            }.padding()
            HStack {
                Spacer()
                VStack {
                    DeviceView(device: settings.devices[selectedDevice])
                    Button(action: {
                        if self.appDelegate?.deleteDevice(indexOf: self.selectedDevice) ?? false {
                            if self.selectedDevice > 0 {
                                self.selectedDevice -= 1
                            }
                        }
                    }) {
                        Text("Löschen...")
                    }
                }
                Spacer()
            }
        }
    }*/
    var body: some View {
        NavigationView {
            List {
                ForEach(settings.devices) { device in
                    
                }
                // ANzahl!
            }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
