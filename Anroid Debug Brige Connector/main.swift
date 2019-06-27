//
//  main.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 24.06.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let appDelegate = AppDelegate()
app.delegate = appDelegate
app.run()
