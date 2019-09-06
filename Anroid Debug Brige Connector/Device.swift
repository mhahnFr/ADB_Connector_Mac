//
//  Device.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 04.09.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

/// Ein Objekt dieser Klasse repräsentiert ein Androidgerät.
class Device {
    /// Der Name des Geräts.
    var deviceName: String
    /// Die IP-Adresse des Geräts.
    var ipAddress: String?
    /// Zeigt an, ob der Port für dieses Gerät bereits geöffnet wurde oder nicht.
    var openedPort = false
    /// Wie und ob dieses Gerät mit der ADB verbunden ist.
    var connectionType: ConnectionType?
    /// Der zu verwendende Port für dieses Gerät. Sollte kein Port gsetzt sein, muss der
    /// Standardport verwendet werden.
    var lanPort: Int?
    
    /// Initialisiert die Repräsentation.
    ///
    /// - Parameter name: Der Name des Geräts.
    /// - Parameter ipAddress: Die IP-Adresse des Geräts, kann auch leer bleiben.
    init(name: String, ipAddress: String?) {
        deviceName = name
        self.ipAddress = ipAddress
    }
    
    /// Initialisiert die Repräsentation ohne IP-Adresse.
    ///
    /// - Parameter name: Der Name des Geräts.
    convenience init(_ name: String) {
        self.init(name: name, ipAddress: nil)
    }

    /// Der verwendete Verbindungstyp.
    enum ConnectionType {
        case USB, LAN
    }
}
