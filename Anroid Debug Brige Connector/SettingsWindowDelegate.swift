//
//  SettingsWindowDelegate.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 02.09.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import Cocoa

class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApp.stopModal()
        return true
    }
}
