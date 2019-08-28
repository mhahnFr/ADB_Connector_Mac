//
//  AppDelegate.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 24.06.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    /// Das Hauptfenster.
    var window: NSWindow!
    /// Der Pfad zur Android Debug Bridge (adb).
    let pathToADB = "~/Library/Android/sdk/platform-tools/adb"
    /// Das Label mit dem Text für den Nutzer.
    var label: NSTextField!
    /// Der Timer, der den Ablauf steuert.
    var timer: Timer!
    /// Der Gerätename, muss vor Benutzung erst noch initialisiert werden.
    var deviceName: String?
    /// Die IP-Addresse des Androidgeräts, muss vor der Benutzung initialisiert werden.
    var ipAddress: String?
    /// Ein Wahrheitswert, mit dem das Blinken im GUI ermöglicht wird.
    var blinkON = false
    /// Der Zähler für das Erfolgsblinken.
    var greenCounter = 0
    /// Der Knopf zum direkten Verbinden über (W)LAN.
    var skipButton: NSButton?
    /// Der LAN-Port, der zur (W)LAN-Verbindung auf dem Androidgerät geöffnet werden soll.
    let lanPort = 5555
    /// Die zuletzt durchgeführte Aktion.
    var lastAction: Action? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let s = NSScreen.main?.frame
        window = NSWindow(contentRect: NSMakeRect(s?.origin.x ?? 0, (s?.height ?? 500) - 1, 685, 60), styleMask: NSWindow.StyleMask(rawValue: 0), backing: NSWindow.BackingStoreType.buffered, defer: true)
        window.title = "ADB Connector"
        label = NSTextField(frame: NSMakeRect(0, 0, 680, 20))
        label.isBezeled = false
        label.isEditable = false
        label.stringValue = "Bitte Verbindung per USB herstellen. Bitte Verbindung per USB herstellen. Bitte Verbindung per USB herstellen."
        label.sizeToFit()
        let abortButton = NSButton(title: "Abbrechen", target: nil, action: #selector(abort))
        skipButton = NSButton(title: ">>", target: self, action: #selector(skip))
        let gridButtons = NSStackView(views: [abortButton, skipButton!])
        gridButtons.orientation = .horizontal
        let mainGrid = NSStackView(views: [label, gridButtons])
        mainGrid.orientation = .vertical
        window.contentView = mainGrid
        window.makeKeyAndOrderFront(self)
        
        // NUR ZUM AUFBAUEN!
        let standardAction = #selector(menuChoosen)
        // Das erste NSMenu ist die Menüzeile
        let menubar = NSMenu()
        
        // In die Menüzeile werden die Menüs als NSMenuItem mit submenu eingefügt
        let applicationMenuBar = NSMenuItem(title: "Application", action: nil, keyEquivalent: "")
        menubar.addItem(applicationMenuBar)
        let applicationMenu = NSMenu()
        applicationMenuBar.submenu = applicationMenu
        let applicationMenuServices = NSMenu()
        NSApp.servicesMenu = applicationMenuServices
        applicationMenu.addItem(withTitle: "Über ADB Connector", action: standardAction, keyEquivalent: "")
        applicationMenu.addItem(NSMenuItem.separator())
        applicationMenu.addItem(withTitle: "Einstellungen", action: standardAction, keyEquivalent: ",")
        applicationMenu.addItem(NSMenuItem.separator())
        let services = NSMenuItem(title: "Dienste", action: standardAction, keyEquivalent: "")
        services.submenu = applicationMenuServices
        applicationMenu.addItem(services)
        applicationMenu.addItem(NSMenuItem.separator())
        applicationMenu.addItem(withTitle: "ADB Connector ausblenden", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthers = NSMenuItem(title: "Andere ausblenden", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        applicationMenu.addItem(hideOthers)
        applicationMenu.addItem(withTitle: "Alle einblenden", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        applicationMenu.addItem(NSMenuItem.separator())
        applicationMenu.addItem(withTitle: "ADB Connector beenden", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let deviceMenuBar = NSMenuItem(title: "Gerät", action: nil, keyEquivalent: "")
        menubar.addItem(deviceMenuBar)
        let deviceMenu = NSMenu(title: "Gerät")
        deviceMenuBar.submenu = deviceMenu
        deviceMenu.addItem(withTitle: "IP-Adresse eingeben...", action: #selector(menuSetIPAddress), keyEquivalent: "")
        deviceMenu.addItem(withTitle: "Name eingeben...", action: #selector(menuSetDeviceName), keyEquivalent: "")
        NSApp.mainMenu = menubar
        
        deviceName = setDeviceName()
        if canStart() {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectUSB), userInfo: nil, repeats: true)
        }
    }
    
    /// Gibt zurück, ob sich dieses Programm mit einem Androidgerät verbinden kann oder nicht.
    ///
    /// - Returns: Ob alle Einstellungen, die nötig sind, eingestellt sind.
    private func canStart() -> Bool {
        return deviceName != nil && deviceName != nil
    }
    
    /// Stellt den Namen des Geräts ein. Wird vom Nutzer ausgelöst.
    @objc func menuSetDeviceName() {
        deviceName = setDeviceName(cancellable: true) ?? deviceName
    }
    
    /// Stellt die IP-Addresse des Androidgeräts ein. Wird vom Nutzer ausgelöst.
    @objc func menuSetIPAddress() {
        ipAddress = setIPAddress(userInfo: nil, cancellable: true) ?? ipAddress
    }
    
    /// Nur zum Aufbau des GUIs.
    @objc func menuChoosen() {
        print("Menü betätigt!")
    }
    
    /// Befragt den Nutzer nach dem Namen seines Androidgeräts. Sollte der Nutzer den Dialog abbrechen,
    /// wird nil zurückgegeben. Standardmäßig kann der Dialog nicht abgebrochen werden.
    ///
    /// - Parameter cancellable: Ob ein Abbruchsknopf angezeigt werden soll (standardmäßig false).
    /// - Returns: Den vom Nutzer eingegebenen Gerätenamen oder nil bei Abbruch.
    func setDeviceName(cancellable: Bool = false) -> String? {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Bitte den Gerätenamen eingeben:"
        alert.informativeText = "Dies ist der Name des Geräts, wenn es per USB verbunden wird."
        let textField = NSTextField(frame: NSMakeRect(0, 0, 200, 20))
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        if cancellable {
            alert.addButton(withTitle: "Cancel")
        }
        //alert.beginSheetModal(for: window, completionHandler: nil)
        if alert.runModal() == .alertSecondButtonReturn {
            return nil
        }
        return textField.stringValue
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /// Überprüft, ob das Androidgerät noch angeschlossen ist. Sollte dies der Fall
    /// sein, wird false zurückgegeben und eine entsprechende Nachricht angezeigt.
    ///
    /// - Returns: Ob das Androidgerät getrennt wurde
    private func disconnectUSB() -> Bool {
        if blinkON {
            inform("Bitte USB-Verbindung von \(deviceName!) trennen.", .no_flag)
            blinkON = false
        } else {
            inform("Bitte USB-Verbindung von \(deviceName!) trennen.", .warning)
            blinkON = true
        }
        let ioText = execADB("devices", "-l")
        if ioText.contains(deviceName!) {
            return false
        }
        inform("Verbindung getrennt.", .no_flag)
        blinkON = false
        return true
    }
    
    private func superDisconnectUSB() -> Bool {
        // Keine Ahnung, was da in Java noch nötig war...
        return disconnectUSB()
    }
    
    /// Versucht sich vollständig mit dem Androidgerät zu verbinden. Sollte es an irgendeiner Stelle
    /// später noch einmal versucht werden müssen, wird ein entsprechender Timer gestartet.
    @objc func timerConnectUSB() {
        if connectUSB() {
            /*if !openLANPort() {
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerOpenLANPort), userInfo: nil, repeats: true)
            } else {
                if !superDisconnectUSB() {
                    timer.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerSuperDisconnectUSB), userInfo: nil, repeats: true)
                } else {
                    if !connectWLAN() {
                        timer.invalidate()
                        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
                    } else {
                        timer.invalidate()
                        if !checkWLANConnection() {
                            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
                        } else {
                            inform("Verbunden.", .success)
                            blinkON = true
                            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
                        }
                    }
                }
            }*/
            lastAction = .connectUSB
            timerOpenLANPort()
        }
        lastAction = .connectUSB
    }
    
    /// Versucht sich mit dem Androidgerät zu verbinden ab dem unkt des Port Öffnens. Sollte es an irgendeiner Stelle
    /// später noch einmal versucht werden müssen, wird ein entsprechender Timer gestartet.
    @objc func timerOpenLANPort() {
        if openLANPort() {
            /*if !superDisconnectUSB() {
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerSuperDisconnectUSB), userInfo: nil, repeats: true)
            } else {
                if !connectWLAN() {
                    timer.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
                } else {
                    timer.invalidate()
                    if !checkWLANConnection() {
                        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
                    } else {
                        inform("Verbunden.", .success)
                        blinkON = true
                        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
                    }
                }
            }*/
            lastAction = .openLANPort
            timerSuperDisconnectUSB()
        } else {
            if let la = lastAction {
                if la == .connectUSB {
                    timer.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerOpenLANPort), userInfo: nil, repeats: true)
                }
            }
        }
        lastAction = .openLANPort
    }
    
    @objc func timerSuperDisconnectUSB() {
        if superDisconnectUSB() {
            /*if !connectWLAN() {
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
            } else {
                timer.invalidate()
                if !checkWLANConnection() {
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
                } else {
                    inform("Verbunden.", .success)
                    blinkON = true
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
                }
            }*/
            lastAction = .disconnectUSB
            timerConnectWLAN()
        } else {
            if let la = lastAction {
                if la == .openLANPort {
                    timer.invalidate()
                    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerSuperDisconnectUSB), userInfo: nil, repeats: true)
                }
            }
        }
        lastAction = .disconnectUSB
    }
    
    @objc func timerConnectWLAN() {
        if connectWLAN() {
            timer.invalidate()
            if !checkWLANConnection() {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
            } else {
                inform("Verbunden.", .success)
                blinkON = true
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func timerCheckWLANConnection() {
        if checkWLANConnection() {
            inform("Verbunden.", .success)
            blinkON = true
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
        }
    }
    
    @objc func blinkGreen() {
        if greenCounter < 10 {
            if !checkWLANConnection() {
                greenCounter = 0
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCheckWLANConnection), userInfo: nil, repeats: true)
            }
            if blinkON {
                inform("Verbunden.", .no_flag)
                blinkON = false
            } else {
                inform("Verbunden.", .success)
                blinkON = true
            }
            greenCounter += 1
        } else {
            NSApp.terminate(self)
        }
    }
    
    /// Überprüft, ob das Androidgerät mit der ADB verbunden ist.
    ///
    /// - Returns: Ob das Androidgerät mit der ADB verbunden ist.
    private func checkWLANConnection() -> Bool {
        inform("WLAN-Verbindung mit \(deviceName!) (\(ipAddress!)) wird überprüft...", .no_flag)
        let ioText = execADB("devices", "-l")
        if ioText.contains(ipAddress!) {
            inform("ADB verbunden mit \(deviceName!) (\(ipAddress!)).", .success)
            return true
        }
        inform("Nicht mit \(deviceName!) (\(ipAddress!)) verbunden!", .error)
        return false
    }
    
    /// Befragt den Nutzer nach der IP-Adresse seines Geräts. Sollte der Nutzer den Dialog abbrechen,
    /// wird nil zurückgegeben. Standardmäßig kann der Dialog nicht abgebrochen werden.
    ///
    /// - Parameter userInfo: Falls dem Nutzer noch etwas zusätzlich mitgeteilt werden soll.
    /// - Parameter cancellable: Ob ein Abbruchsknopf angezeigt werden soll (standardmäßig false).
    /// - Returns: Die vom Nutzer eingegebene IP-Adresse oder nil bei Abbruch.
    private func setIPAddress(userInfo: String?, cancellable: Bool = false) -> String? {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Bitte die IP-Adresse von \(deviceName ?? "ihrem Gerät") eingeben:"
        alert.informativeText = "Dies ist die IP-Adresse ihres Geräts, zu finden in den Netzwerkeinstellungen auf dem Gerät. \(userInfo ?? "")"
        let textField = NSTextField(frame: NSMakeRect(0, 0, 200, 20))
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        if cancellable {
            alert.addButton(withTitle: "Cancel")
        }
        //alert.beginSheetModal(for: window, completionHandler: nil)
        if alert.runModal() == .alertSecondButtonReturn {
            return nil
        }
        return textField.stringValue
    }
    
    /// Versucht sich per (W)LAN mit dem Androidgerät zu verbinden. Sollte die IP-Addresse falsch sein,
    /// wird sie vom Nutzer erfragt oder das Programm beendet.
    ///
    /// - Returns: Ob das Androidgerät erolgreich verbunden wurde.
    private func connectWLAN() -> Bool {
        if ipAddress == nil {
            ipAddress = setIPAddress(userInfo: nil)
        }
        inform("WLAN-Verbindung mit \(deviceName!) wird aufgebaut...", .no_flag)
        let ioText = execADB("connect", "\(ipAddress!):\(lanPort)")
        if ioText.contains("unable") && ioText.contains("connect") {
            timer.invalidate()
            inform("Falsche IP-Addresse", .error)
            ipAddress = setIPAddress(userInfo: "Falsche IP-Adresse!")
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
            return false
        }
        if ioText.contains("connected") {
            inform("Per WLAN mit \(deviceName!) (\(ipAddress!)) verbunden.", .success)
            return true
        }
        return false
    }
    
    /// Versucht, den LAN-Port auf dem Androidgerät zu öffnen, so dass es sich per (W)LAN verbinden kann.
    ///
    /// - Returns: Ob der Port erfolgreich geöffnet wurde
    private func openLANPort() -> Bool {
        inform("LAN-Port wird geöffnet...", .no_flag)
        let ioText = execADB("tcpip", "\(lanPort)")
        if ioText.contains("error") {
            inform("adb konnte LAN-Port nicht öffnen!", .error)
            return false
        }
        if ioText.contains("restarting") && ioText.contains("TCP mode") {
            inform("LAN-Port erfolgreich geöffnet. Port: \(lanPort)", .success)
            return true
        }
        return false
    }
    
    /// Leitet den Befehl des Springenknopfes an [mainAction(action:)](x-source-tag://mainAction(action:)) weiter.
    @objc func skip() {
        if lastAction == Action.connectUSB || lastAction == Action.disconnectUSB {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
            skipButton?.isEnabled = false
        }
    }
    
    /// Leitet den Befehl des Abbrechenknopfes an [mainAction(action:)](x-source-tag://mainAction(action:)) weiter.
    @objc func abort() {
        NSApp.terminate(self)
    }
    
    /// Gibt zurück, ob das gesuchte Gerät in der Liste der verbundenen Geräte erscheint.
    ///
    /// - Returns: Ob das Gerät gefunden wurde.
    private func connectUSB() -> Bool {
        inform("Es wird nach \(deviceName ?? "Gerätename") gesucht...", .no_flag)
        let ioText = execADB("devices", "-l")
        if ioText.contains(deviceName!) {
            return true
        }
        if blinkON {
            inform("Bitte Verbindung per USB herstellen.", .no_flag)
            blinkON = false
        } else {
            inform("Bitte Verbindung per USB herstellen.", .warning)
            blinkON = true
        }
        return false
    }
    
    /// Führt den angegebenen Befehl in der Kommandozeile aus.
    ///
    /// - Parameter command: Der auszuführende Befehl.
    /// - Returns: Das Ergebnis, das vom Prozess ausgegeben wurde.
    private func execADB(_ command: String...) -> String {
        let p = Process()
        p.launchPath = pathToADB
        p.arguments = command
        let pipe = Pipe()
        p.standardOutput = pipe
        p.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return String(data: data, encoding: String.Encoding.utf8) ?? "missing value"
    }
    
    /// Zeigt den angegebenen Text entsprechend des angegebenen Modus an.
    ///
    /// - Parameter text: Der anzuzeigende Text.
    /// - Parameter mode: Der Modus, in welchem der Text angezeigt werden soll.
    private func inform(_ text: String, _ mode: Mode) {
        label.stringValue = text
        print("\(text), \(mode)")
        switch mode {
        case .success:
            label.backgroundColor = NSColor.systemGreen
            label.textColor = NSColor.black
            
        case .error:
            label.backgroundColor = NSColor.systemRed
            label.textColor = NSColor.white
            
        case .warning:
            label.backgroundColor = NSColor.systemYellow
            label.textColor = NSColor.black
            
        default:
            label.backgroundColor = NSColor.clear
            label.textColor = NSColor.black
        }
    }
}
