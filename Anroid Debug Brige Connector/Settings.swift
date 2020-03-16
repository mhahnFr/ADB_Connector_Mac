//
//  Settings.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 04.09.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import SwiftUI

/// Diese Klasse kümmert sich um alle Einstellungen, die von der App gespeichert werden
/// müssen.
class Settings: ObservableObject {
    /// The singleton representation.
    static let shared = Settings()
    /// Der Port, der standardmäßig zur Verbindung über (W)LAN verwendet wird.
    @State
    var standardLANPort = 5555
    /// Eine automatisierte Repräsentation des LAN-Ports als String. Wird ein nicht als Int umwandelbarer Wert übergeben,
    /// wird weder diese noch die Zahlenvariable geändert.
    var standardLANPortString: String {
        get {
            "\(standardLANPort)"
        }
        set {
            print(newValue)
            standardLANPort = Int(newValue) ?? standardLANPort
        }
    }
    /// Die Liste mit den Geräten. Sie ist published, um direkt in der Geräteliste des GUIs angezeigt werden zu können.
    @Published
    var devices: [Device] = []
    
    /// Konstruktor mit Arbeit, die nur in einer Testumgebung auszuführen sind.
    private init() {
        #if DEBUG
        devices = testDevices
        #endif
    }
}
