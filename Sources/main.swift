import AppKit
import Foundation

class CoffeeApp: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var caffeinateProcess: Process?
    private var isActive = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.action = #selector(toggleCaffeinate)
            button.target = self
            updateIcon()
        }
        
        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Caffeinate", action: #selector(toggleCaffeinate), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        stopCaffeinate()
    }
    
    @objc private func toggleCaffeinate() {
        if isActive {
            stopCaffeinate()
        } else {
            startCaffeinate()
        }
    }
    
    private func startCaffeinate() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-d"]
        
        do {
            try process.run()
            caffeinateProcess = process
            isActive = true
            updateIcon()
        } catch {
            print("Failed to start caffeinate: \(error)")
        }
    }
    
    private func stopCaffeinate() {
        caffeinateProcess?.terminate()
        caffeinateProcess = nil
        isActive = false
        updateIcon()
    }
    
    private func updateIcon() {
        guard let button = statusItem.button else { return }
        
        if isActive {
            // Filled coffee cup - caffeinate is ON
            button.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Caffeinate On")
        } else {
            // Empty coffee cup - caffeinate is OFF
            button.image = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: "Caffeinate Off")
        }
    }
    
    @objc private func quit() {
        stopCaffeinate()
        NSApplication.shared.terminate(nil)
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = CoffeeApp()
app.delegate = delegate

// Set activation policy to accessory (no dock icon)
app.setActivationPolicy(.accessory)

app.run()
