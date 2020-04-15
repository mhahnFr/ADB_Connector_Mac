//
//  Device.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 04.09.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import Foundation
import SwiftUI

/// Ein Objekt dieser Klasse repräsentiert ein Androidgerät.
@objc class Device: NSObject, Identifiable, ObservableObject {
    /// Die ID dieses Geräts, wird benötigt für SwiftUI.
    var id = UUID()
    /// Der Name des Geräts.
    var deviceName: String
    /// Die IP-Adresse des Geräts.
    var ipAddress: String?
    /// Zeigt an, ob der Port für dieses Gerät bereits geöffnet wurde oder nicht.
    var openedPort = false
    /// This value is used to slow down the disconnection process.
    var firstDisconnectionTry = true
    /// Wie und ob dieses Gerät mit der ADB verbunden ist.
    var connectionType: ConnectionType?
    /// Der zu verwendende Port für dieses Gerät. Sollte kein Port gsetzt sein, muss der
    /// Standardport verwendet werden.
    var lanPort: Int?
    /// The timer needed for the connection process.
    var timer: Timer?
    /// The last action that has been done during the connection process. If no action is set, the connection process has not yet started.
    var lastConnectingAction: Action?
    /// A message that is continually displayed in the view of this device.
    @Published
    var userMessage = ""
    /// The mode in which the message has to be displayed.
    var mode = Mode.no_flag
    /// The indicator wether blinking message should flash this time or not.
    var blinkON = false
    /// A counter for how often to blink green when succesfully connected.
    var greenCounter = 0
    
    /// Initialisiert die Repräsentation. Sollte der Name ein leerer String sein, wird
    /// ein Standardname vergeben.
    ///
    /// - Parameter name: Der Name des Geräts.
    /// - Parameter ipAddress: Die IP-Adresse des Geräts, kann auch leer bleiben.
    init(name: String, ipAddress: String?) {
        if name == "" {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            deviceName = "Device \(day).\(month).\(year) \(hour):\(minute)"
        } else {
            deviceName = name
        }
        self.ipAddress = ipAddress
    }
    
    /// Initialisiert die Repräsentation ohne IP-Adresse.
    ///
    /// - Parameter name: Der Name des Geräts.
    convenience init(_ name: String) {
        self.init(name: name, ipAddress: nil)
    }

    /// Initiates the connection process. Asks the user for the ip address if necessary.
    public func startConnecting() {
        if lastConnectingAction == nil {
            if ipAddress == nil {
                // Braucht Überarbeitung!!!
                let address = (NSApp.delegate as? AppDelegate)?.setIPAddress(userInfo: nil, cancellable: true, deviceName: deviceName, ipAddress: nil)
                if address == nil {
                    return
                }
            }
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectUSB), userInfo: nil, repeats: true)
        } else {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Soll der Verbindungsprozess abgebrochen werden?"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == .alertFirstButtonReturn {
                timer?.invalidate()
                mode = .no_flag
                userMessage = ""
            }
        }
    }
    
    /// Starts the connection process.
    @objc private func timerConnectUSB() {
        if connectUSB() {
            lastConnectingAction = .connectUSB
            timerOpenLANPort()
        }
        lastConnectingAction = .connectUSB
    }
    
    /// Tries to open the specified LAN-Port on this device. If it fails, a timer is started to try it again. Otherwise the next step
    /// of the connection process is started.
    @objc private func timerOpenLANPort() {
        if openLANPort() {
            lastConnectingAction = .openLANPort
            timerDisconnectUSB()
        } else {
            if let lastAction = lastConnectingAction {
                if lastAction == .connectUSB {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerOpenLANPort), userInfo: nil, repeats: true)
                }
            }
        }
        lastConnectingAction = .openLANPort
    }
    
    /// Checks wether the device is disconnected. If this is not the case, a timer for continuously checking is started. Once the
    /// device is disconnected, the next step in the connection process is started.
    @objc private func timerDisconnectUSB() {
        if disconnectUSB() {
            lastConnectingAction = .disconnectUSB
            timerConnectWLAN()
        } else {
            if let lastAction = lastConnectingAction {
                if lastAction == .openLANPort {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerDisconnectUSB), userInfo: nil, repeats: true)
                }
            }
        }
        lastConnectingAction = .disconnectUSB
    }
    
    /// Tries to connect the device using (W)LAN. If it was successful, the connection will be checked by another timer.
    @objc private func timerConnectWLAN() {
        if connectWLAN() {
            timer?.invalidate()
            if !checkWLANConnection() {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
            } else {
                mode = .success
                userMessage = "Verbunden."
            }
        }
    }
    
    /// Checks if the connection of this device is established.
    @objc private func timerCheckWLANConnection() {
        if checkWLANConnection() {
            mode = .success
            userMessage = "Verbunden."
            blinkON = true
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
        }
    }
    
    /// Makes the text in its associated view blink green. It meanwhile checks the establishement of the connection. If the
    /// connection is interrupted, the control is given back to the checking method.
    @objc private func blinkGreen() {
        if greenCounter < 10 {
            if !checkWLANConnection() {
                greenCounter = 0
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
            }
            if blinkON {
                mode = .no_flag
                blinkON = false
            } else {
                mode = .success
                blinkON = true
            }
            userMessage = "Verbunden."
            greenCounter += 1
        }
    }
    
    /// Checks and returns wether this device schows up in the list of the connected devices,
    ///
    /// - Returns: Wether the device was found in the list.
    private func connectUSB() -> Bool {
        mode = .no_flag
        userMessage = "Es wird nach \(deviceName) gesucht..."
        let ioText = execADB("devices", "-l")
        if ioText.contains(deviceName) {
            return true
        }
        if blinkON {
            mode = .no_flag
            blinkON = false
        } else {
            mode = .warning
            blinkON = true
        }
        userMessage = "Bitte Verbindung per USB herstellen."
        return false
    }
    
    /// Tries to open the LAN-port. If it is not set in this device, the default value provided by the settings object is used.
    ///
    /// - Returns: True if, and only if the port has been opened, false otherwise.
    private func openLANPort() -> Bool {
        mode = .no_flag
        userMessage = "LAN-Port wird geöffnet..."
        let ioText = execADB("tcpip", "\(lanPort ?? Settings.shared.standardLANPort)")
        if ioText.contains("error") {
            mode = .error
            userMessage = "ADB konnte LAN-Port nicht öffnen!"
            return false
        }
        if ioText.contains("restarting") && ioText.contains("TCP mode") {
            mode = .success
            userMessage = "LAN-Port geöffnet. Port: \(lanPort ?? Settings.shared.standardLANPort)"
            openedPort = true
            return true
        }
        return false
    }
    
    /// Tells the user to disconnect its device. If this device is disconnected, this method returns true.
    ///
    /// - Returns: Wether this device is disconnected.
    private func disconnect() -> Bool {
        if blinkON {
            mode = .no_flag
            blinkON = false
        } else {
            mode = .warning
            blinkON = true
        }
        userMessage = "Bitte USB-Verbindung von \(deviceName) trennen."
        let ioText = execADB("devices", "-l")
        if ioText.contains(deviceName) {
            return false
        }
        mode = .no_flag
        userMessage = "Verbindung getrennt."
        blinkON = false
        return true
    }
    
    /// The intention of this function is to slow down the disconnection process. When firstly invoced, asserts that this device is connected using USB. At the second invocation, it checks wether this device is disconnected.
    ///
    /// - Returns: Wether this device is not connected.
    private func disconnectUSB() -> Bool {
        if firstDisconnectionTry {
            if connectUSB() {
                firstDisconnectionTry = false
            }
            return false
        } else {
            return disconnectUSB()
        }
    }
    
    /// Checks wether this device is connected using (W)LAN.
    ///
    /// - Returns: True, if this device is connect via the local network, false otherwise.
    private func checkWLANConnection() -> Bool {
        mode = .no_flag
        userMessage = "WLAN-Verbindung mit \(deviceName) (\(ipAddress!)) wird überprüft..."
        let ioText = execADB("devices", "-l")
        if ioText.contains(ipAddress!) {
            mode = .success
            userMessage = "ADB vebunden mit \(deviceName) (\(ipAddress!))."
            return true
        }
        mode = .error
        userMessage = "Nicht mit \(deviceName) (\(ipAddress!)) verbunden!"
        return false
    }
    
    /// Tries to connect to this device using (W)LAN. If the IP address seems to be wrong, propmts the user to either enter the correct IP address or abort the process.
    ///
    /// - Returns: If this device has been connected.
    private func connectWLAN() -> Bool {
        mode = .no_flag
        userMessage = "WLAN-Verbindung mit \(deviceName) wird aufgebaut..."
        let ioText = execADB("connect", "\(ipAddress!):\(lanPort ?? Settings.shared.standardLANPort)")
        if ioText.contains("missing port") {
            timer?.invalidate()
            mode = .error
            userMessage = "Falsche IP-Adresse"
            // Prompt user to enter correct IP-address or to abort the processs.
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
            return false
        }
        if ioText.contains("connected") {
            mode = .success
            userMessage = "Per WLAN mit \(deviceName) (\(ipAddress!)) verbunden."
            return true
        }
        return false
    }
    
    /// Executes the given command in the system commandline.
    ///
    /// - Parameter command: The command to be executed.
    /// - Returns: The result of the process.
    private func execADB(_ command: String...) -> String {
        let p = Process()
        p.launchPath = "~/Library/Android/sdk/platform-tools/adb"
        p.arguments = command
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe
        p.launch()
        // TODO Unbedingt korrigieren, friert hier ein wenn IP-Adresse falsch ist!
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return String(data: data, encoding: String.Encoding.utf8) ?? "missing value"
    }
    
    /// Der verwendete Verbindungstyp.
    enum ConnectionType {
        case USB, LAN
    }
}
#if DEBUG
let testDevices = [
    Device(name: "MotoG3", ipAddress: "127.0.0.1"),
    Device("P30 Pro"),
    Device("iPhone 5"),
    Device("MatePad Pro")
]
#endif
