//
//  Action.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 25.06.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import Foundation

/// Eine Aufzählung der Zwischenschritte des Herstellens der Verbindung zum Androidgerät.
public enum Action {
    /// Der Vorgang soll abgebrochen werden.
    case abort
    /// Das Gerät wird über USB verbinden.
    case connectUSB
    /// Der LAN-Port wird geöffnet.
    case openLANPort
    /// Das Gerät soll getrennt werden.
    case disconnectUSB
    /// Das Gerät soll über (W)LAN verbunden werden.
    case connectWLAN
    /// Die (W)LAN-Verbindung wird überprüft.
    case checkWLANConnection
}
