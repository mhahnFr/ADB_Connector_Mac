//
//  Mode.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 27.06.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import Foundation

/// Eine Aufzählung der Anzeigemodi.
enum Mode {
    /// Wenn Erfolg angezeigt werden soll.
    case success
    /// Wenn ein Fehler angezeigt werden soll.
    case error
    /// Wenn eine Warnung angezeigt werden soll.
    case warning
    /// Wenn etwas ganz normal angezeigt werden soll.
    case no_flag
}
