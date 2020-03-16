//
//  AppDelegate.swift
//  Anroid Debug Brige Connector
//
//  Created by Manuel Hahn on 24.06.19.
//  Copyright © 2019 Manuel Hahn. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    /// Das Hauptfenster.
    var window: NSWindow!
    /*/// Das Fenster für die Einstellungen.
    var settingsWindow: NSWindow?*/
    /// Der Pfad zur Android Debug Bridge (adb).
    let pathToADB = "~/Library/Android/sdk/platform-tools/adb"
    /// Das Label mit dem Text für den Nutzer.
    var label: NSTextField!
    /// Der Timer, der den Ablauf steuert.
    var timer: Timer!
    /*/// Der Gerätename, muss vor Benutzung erst noch initialisiert werden.
    var deviceName: String?*/
    /*/// Die IP-Addresse des Androidgeräts, muss vor der Benutzung initialisiert werden.
    var ipAddress: String?*/
    /// Ein Wahrheitswert, mit dem das Blinken im GUI ermöglicht wird.
    var blinkON = false
    /// Der Zähler für das Erfolgsblinken.
    var greenCounter = 0
    /*/// Der Knopf zum direkten Verbinden über (W)LAN.
    var skipButton: NSButton?*/
    /*/// Der LAN-Port, der zur (W)LAN-Verbindung auf dem Androidgerät geöffnet werden soll.
    var lanPort = 5555*/
    /// Die zuletzt durchgeführte Aktion.
    var lastAction: Action? = nil
    /// Ein Wahrheitswert, mit dem ein Bremse bei der Trennung der USB-Verbindung realisiert
    /// wird.
    var first: Bool = true
    //let devicesList = NSStackView(views: [])
    let nameField = NSTextField()
    let ipField = NSTextField()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /*devicesList.orientation = .vertical
        devicesList.addArrangedSubview(NSButton(title: "Gerät hinzufügen...", target: self, action: #selector(addDevice)))
        let nameLabel = NSTextField(labelWithString: "Gerätename:")
        let ipLabel = NSTextField(labelWithString: "IP-Adresse:")
        let useDefaultPort = NSButton(checkboxWithTitle: "Standardport verwenden", target: self, action: nil)
        let devicesPane = NSStackView(views: [nameLabel, nameField, ipLabel, ipField, useDefaultPort])
        devicesPane.orientation = .vertical
        let mainView = NSStackView(views: [devicesList, devicesPane])
        mainView.orientation = .horizontal
        //window.contentView = mainView
        window.contentView = NSHostingView(rootView: MainView())*/
        /*label = NSTextField(labelWithString: "Bitte Verbindung per USB herstellen. Bitte Verbindung per USB herstellen. Bitte Verbindung per USB herstellen.")
        label.drawsBackground = true
        label.backgroundColor = NSColor.clear
        label.sizeToFit()
        let abortButton = NSButton(title: "Abbrechen", target: nil, action: #selector(abort))
        skipButton = NSButton(title: ">>", target: self, action: #selector(skip))
        let gridButtons = NSStackView(views: [abortButton, skipButton!])
        gridButtons.orientation = .horizontal
        let mainGrid = NSStackView(views: [label, gridButtons])
        mainGrid.orientation = .vertical
        window.contentView = mainGrid*/
        createMenuBar()
        showWindow()
                
        if canStart() {
            /*timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectUSB), userInfo: nil, repeats: true)*/
        } else {
            //addDevice()
        }
    }
    
    /// Creates and installs the menubar.
    func createMenuBar() {
#if DEBUG
        // NUR ZUM AUFBAUEN!
        let standardAction = #selector(menuChoosen)
#endif
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
        applicationMenu.addItem(withTitle: "Einstellungen", action: #selector(showSettings), keyEquivalent: ",")
        applicationMenu.addItem(NSMenuItem.separator())
        let services = NSMenuItem(title: "Dienste", action: nil, keyEquivalent: "")
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
        deviceMenu.addItem(withTitle: "Hinzufügen...", action: #selector(addDevice), keyEquivalent: "n")
        
        let windowMenuBar = NSMenuItem(title: "Fenster", action: nil, keyEquivalent: "")
        let windowMenu = NSMenu(title: "Window")
        NSApp.windowsMenu = windowMenu
        windowMenuBar.submenu = windowMenu
        windowMenu.addItem(withTitle: "Hauptfenster", action: #selector(showWindow), keyEquivalent: "0")
        menubar.addItem(windowMenuBar)
        
        let helpMenuBar = NSMenuItem(title: "Hilfe", action: nil, keyEquivalent: "")
        let helpMenu = NSMenu(title: "Hilfe")
        NSApp.helpMenu = helpMenu
        helpMenuBar.submenu = helpMenu
        helpMenu.addItem(withTitle: "ADB Connector Hilfe", action: standardAction, keyEquivalent: "?")
        menubar.addItem(helpMenuBar)
        
        NSApp.mainMenu = menubar
    }
    
    /// Creates and shows the main window of this application.
    @objc func showWindow() {
        window = createWindow()
        window.makeKeyAndOrderFront(nil)
    }
    
    /// Creates the main window of this application.
    func createWindow() -> NSWindow {
        let contentView = MainView(settings: Settings.shared)
        let toReturn = NSWindow(contentRect: NSMakeRect(0, 0, 685, 60), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        toReturn.center()
        toReturn.setFrameAutosaveName("ADB Connector")
        toReturn.title = "ADB Connector"
        toReturn.contentView = NSHostingView(rootView: contentView)
        toReturn.isReleasedWhenClosed = false
        return toReturn
    }
    
    /// Fügt ein Androidgerät der Liste hinzu.
    @objc func addDevice() {
        if let name = setDeviceName(cancellable: true) {
            Settings.shared.devices.append(Device(name: name, ipAddress: setIPAddress(userInfo: nil, cancellable: true)))
        /*if devicesList.views.count == 1 && (devicesList.views[0] as? NSButton)?.title == "Gerät hinzufügen..." {
                devicesList.removeView(devicesList.views[0])*/
            //}
            //let deviceLabel = NSButton(title: name, target: self, action: #selector(selectDevice(_:)))
            //devicesList.addArrangedSubview(deviceLabel)
        }
    }
    
    /// Deletes the device with the given index from the list, if the user confirms it.
    ///
    /// - Returns: The choice given by the user.
    func deleteDevice(indexOf device: Int) -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Möchten Sie das Gerät \"\(Settings.shared.devices[device].deviceName)\" wirklich entfernen?"
        alert.informativeText = "Dieser Vorgang kann nicht widerrufen werden."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            Settings.shared.devices.remove(at: device)
            return true
        }
        return false
    }
    
    /*@objc func selectDevice(_ device: Device) {
        print(device)
    }*/
    
    /// Shows the window for the settings, which will be created.
    @objc func showSettings() {
        let sw = createSettingsDialog()
        NSApp.runModal(for: sw)
    }
    
    /// Zeigt einen Dialog, in dem der Nutzer den zu verwendenden Port ändern kann.
    @objc func changePort() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Bitte den zu verwendenen TCP/IP-Port eingeben:"
        alert.informativeText = "Dieser Port wird verwendet, um das Androidgerät darüber zu verbinden."
        let textField = NSTextField(frame: NSMakeRect(0, 0, 200, 20))
        alert.accessoryView = textField
        textField.stringValue = Settings.shared.standardLANPortString
        textField.selectText(self)
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = textField
        if alert.runModal() == .alertFirstButtonReturn {
            //settings.standardLANPort = Int(textField.stringValue) ?? settings.standardLANPort
            Settings.shared.standardLANPortString = textField.stringValue
        }
    }
    
    /// Gibt zurück, ob sich dieses Programm mit einem Androidgerät verbinden kann oder nicht.
    ///
    /// - Returns: Ob alle Einstellungen, die nötig sind, eingestellt sind.
    private func canStart() -> Bool {
        //return deviceName != nil && deviceName != nil
        return !Settings.shared.devices.isEmpty
    }
    
#if DEBUG
    /// Nur zum Aufbau des GUIs.
    @objc func menuChoosen() {
        print("Menü betätigt!")
    }
#endif
    
    /// Befragt den Nutzer nach dem Namen seines Androidgeräts. Sollte der Nutzer den Dialog
    /// abbrechen, wird nil zurückgegeben. Standardmäßig kann der Dialog nicht abgebrochen
    /// werden. Sollte der Gerätename bereits gesetzt worden sein, wird er zur Bearbeitung
    /// angezeigt.
    ///
    /// - Parameter cancellable: Ob ein Abbruchsknopf angezeigt werden soll (standardmäßig
    /// false).
    /// - Returns: Den vom Nutzer eingegebenen Gerätenamen oder nil bei Abbruch.
    func setDeviceName(cancellable: Bool = false) -> String? {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Bitte den Gerätenamen eingeben:"
        alert.informativeText = "Dies ist der Name des Geräts, wenn es per USB verbunden wird."
        let textField = NSTextField(frame: NSMakeRect(0, 0, 200, 20))
        /*if let dn = deviceName {
            textField.stringValue = dn
        }*/
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        if cancellable {
            alert.addButton(withTitle: "Cancel")
        }
        alert.window.initialFirstResponder = textField
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
        // MARK: deviceName ist hier nur ein Platzhalter! Erstetzen!!!
        let deviceName: String? = "ihr Gerät"
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
    
    /// Diese Funktion soll die Trennung der USB-Verbindung abbremsen.
    private func superDisconnectUSB() -> Bool {
        if first {
            if connectUSB() {
                first = false
            }
            return false
        } else {
            return disconnectUSB()
        }
    }
    
    /// Versucht sich vollständig mit dem Androidgerät zu verbinden. Sollte es an irgendeiner
    /// Stelle später noch einmal versucht werden müssen, wird ein entsprechender Timer
    /// gestartet.
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
    
    /// Versucht sich mit dem Androidgerät zu verbinden ab dem unkt des Port Öffnens. Sollte
    /// es an irgendeiner Stelle später noch einmal versucht werden müssen, wird ein
    /// entsprechender Timer gestartet.
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
    
    /// Versucht, die USB-Verbindung zum Androidgerät zu trennen. Sollte sie noch nicht
    /// getrennt worden sein, wird ein Timer gestartet, wodurch auf die Verbindungstrennung
    /// gewartet werden kann.
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
    
    /// Versucht, sich per (W)LAN mit em Androidgerät zu verbinden. Sollte es nicht
    /// funktionieren, wird ein Timer gestartet, der es immer wieder versucht. Sollte die
    /// Verbindung zustande gekommen sein, wird ein anderer Timer gestartet, der das
    /// Informationstextfeld grün blinken lässt.
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
    
    /// Überprüft, ob das Androidgerät über (W)LAN verbunden ist und startet das
    /// Erfolgsblinken, sollte die Verbindung stehen.
    @objc func timerCheckWLANConnection() {
        if checkWLANConnection() {
            inform("Verbunden.", .success)
            blinkON = true
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkGreen), userInfo: nil, repeats: true)
        }
    }
    
    /// Lässt das Textfeld grün blinken und überprüft gleichzeitig die Verbindung mit dem
    /// Androidgerät.
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
        // MARK: deviceName & ipAddress sind hier nur Platzhalter! Ersetzen!!!
        let deviceName: String? = "ihr Gerät"
        let ipAddress: String? = "127.0.0.1"
        inform("WLAN-Verbindung mit \(deviceName!) (\(ipAddress!)) wird überprüft...", .no_flag)
        let ioText = execADB("devices", "-l")
        if ioText.contains(ipAddress!) {
            inform("ADB verbunden mit \(deviceName!) (\(ipAddress!)).", .success)
            return true
        }
        inform("Nicht mit \(deviceName!) (\(ipAddress!)) verbunden!", .error)
        return false
    }
    
    /// Befragt den Nutzer nach der IP-Adresse seines Geräts. Sollte der Nutzer den Dialog
    /// abbrechen, wird nil zurückgegeben. Standardmäßig kann der Dialog nicht abgebrochen
    /// werden. Sollte die IP-Addresse bereits gesetzt worden sein, wird sie zur Bearbeitung
    /// angezeigt.
    ///
    /// - Parameter userInfo: Falls dem Nutzer noch etwas zusätzlich mitgeteilt werden soll.
    /// - Parameter cancellable: Ob ein Abbruchsknopf angezeigt werden soll (standardmäßig
    /// false).
    /// - Returns: Die vom Nutzer eingegebene IP-Adresse oder nil bei Abbruch.
    private func setIPAddress(userInfo: String?,
                              cancellable: Bool = false,
                              deviceName: String? = nil,
                              ipAddress: String? = nil) -> String? {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Bitte die IP-Adresse von \(deviceName ?? "ihrem Gerät") eingeben:"
        alert.informativeText = "Dies ist die IP-Adresse ihres Geräts, zu finden in den Netzwerkeinstellungen auf dem Gerät. \(userInfo ?? "")"
        let textField = NSTextField(frame: NSMakeRect(0, 0, 200, 20))
        alert.accessoryView = textField
        if let ia = ipAddress {
            textField.stringValue = ia
        }
        alert.addButton(withTitle: "OK")
        if cancellable {
            alert.addButton(withTitle: "Nicht setzen")
        }
        alert.window.initialFirstResponder = textField
        if alert.runModal() == .alertSecondButtonReturn {
            return nil
        }
        return textField.stringValue
    }
    
    /// Versucht sich per (W)LAN mit dem Androidgerät zu verbinden. Sollte die IP-Addresse
    /// falsch sein, wird sie vom Nutzer erfragt oder das Programm beendet.
    ///
    /// - Returns: Ob das Androidgerät erolgreich verbunden wurde.
    private func connectWLAN() -> Bool {
        // MARK: deviceName & ipAddress sind hier nur Platzhalter! Ersetzen!!!
        let deviceName: String? = "ihr Gerät"
        var ipAddress: String? = "127.0.0.1"
        if ipAddress == nil {
            ipAddress = setIPAddress(userInfo: nil)
        }
        inform("WLAN-Verbindung mit \(deviceName!) wird aufgebaut...", .no_flag)
        let ioText = execADB("connect", "\(ipAddress!):\(Settings.shared.standardLANPort)")
        if /*ioText.contains("unable") && ioText.contains("connect")*/ioText.contains("missing port") {
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
    
    /// Versucht, den LAN-Port auf dem Androidgerät zu öffnen, so dass es sich per (W)LAN
    /// verbinden kann.
    ///
    /// - Returns: Ob der Port erfolgreich geöffnet wurde
    private func openLANPort() -> Bool {
        inform("LAN-Port wird geöffnet...", .no_flag)
        let ioText = execADB("tcpip", Settings.shared.standardLANPortString)
        if ioText.contains("error") {
            inform("adb konnte LAN-Port nicht öffnen!", .error)
            return false
        }
        if ioText.contains("restarting") && ioText.contains("TCP mode") {
            inform("LAN-Port erfolgreich geöffnet. Port: \(Settings.shared.standardLANPort)", .success)
            return true
        }
        return false
    }
    
    /// Sorgt dafür, dass sich die ADB sofort mit dem bereits eingestellten Androidgerät
    /// verbindet.
    @objc func skip() {
        if lastAction == Action.connectUSB || lastAction == Action.disconnectUSB {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerConnectWLAN), userInfo: nil, repeats: true)
            //skipButton?.isEnabled = false
        }
    }
    
    /// Beendet das Programm schlicht.
    @objc func abort() {
        NSApp.terminate(self)
    }
    
    /// Gibt zurück, ob das gesuchte Gerät in der Liste der verbundenen Geräte erscheint.
    ///
    /// - Returns: Ob das Gerät gefunden wurde.
    private func connectUSB() -> Bool {
        // MARK: deviceName ist hier nur ein Platzhalter! Ersetzen!!!
        let deviceName: String? = "ihr Gerät"
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
        p.standardError = pipe
        p.launch()
        // TODO Unbedingt korrigieren, friert hier ein wenn IP-Adresse falsch ist!
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

    /// Erzeugt ein Fenster, in welchem die Einstellungen aufgelistet werden. Das erzeugte
    /// Fenster muss mit NSApplication:runModal(forWindow:) angezeigt werden!
    ///
    /// - Returns: Das gerade erzeugte Fenster mit den Einstellungen.
    private func createSettingsDialog() -> NSWindow {
        /*let toReturn = NSWindow(contentRect: NSMakeRect(/*window.frame.origin.x + (window.frame.width / 2), window.frame.origin.y + (window.frame.height / 2)*/0, 0, 200, 75), styleMask: NSWindow.StyleMask(rawValue: NSWindow.StyleMask.closable.rawValue | NSWindow.StyleMask.titled.rawValue), backing: NSWindow.BackingStoreType.buffered, defer: true)
        toReturn.title = "Einstellungen"
        let ipLabel = NSTextField(labelWithString: "Die IP-Adresse des Androidgeräts:")
        let nameLabel = NSTextField(labelWithString: "Der Name des Androidgeräts:")
        let portLabel = NSTextField(labelWithString: "Der für die Verbindung zu verwendende Port:")
        let ipField = NSTextField(string: /*ipAddress ?? */"")
        ipField.placeholderString = "192.168.1.1 oder Mein-Gerät.local"
        let nameField = NSTextField(string: /*deviceName ?? */"")
        nameField.placeholderString = "Gerätemodell oder Name"
        let portField = NSTextField(string: settings.standardLANPortString)
        portField.placeholderString = "Eine Nummer, z. B. 5555"
        let gridView = NSStackView(views: [nameLabel, nameField, ipLabel, ipField, portLabel, portField])
        gridView.orientation = .vertical
        toReturn.contentView = gridView
        let swd = SettingsWindowDelegate()
        toReturn.delegate = swd
        return toReturn*/
        let contentView = SettingsView()
        let toReturn = NSWindow(contentRect: NSMakeRect(0, 0, 200, 75), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        toReturn.center()
        toReturn.setFrameAutosaveName("Einstellungen")
        toReturn.title = "Einstellungen"
        toReturn.contentView = NSHostingView(rootView: contentView)
        toReturn.isReleasedWhenClosed = false
        let swd = SettingsWindowDelegate()
        toReturn.delegate = swd
        return toReturn
    }
}
