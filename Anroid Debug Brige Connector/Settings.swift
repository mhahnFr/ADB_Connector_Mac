//
//  Settings.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 04.09.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

/// Diese Klasse kümmert sich um alle Einstellungen, die von der App gespeichert werden
/// müssen.
class Settings {
    /// Der Port, der standardmäßig zur Verbindung über (W)LAN verwendet wird.
    var standardLANPort = 5555
    /// Die Liste mit den Geräten.
    var devices: [Device] = []
}
