//
//  LidSenseApp.swift
//  LidSense
//

import SwiftUI

@main
struct LidSenseApp: App {
    @StateObject private var reader = LidAngleReader()
    @AppStorage("showInMenuBar") private var showInMenuBar = false

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView(reader: reader)
        }

        MenuBarExtra(isInserted: $showInMenuBar) {
            MenuBarContent(reader: reader)
        } label: {
            Text(menuBarTitle)
        }
    }

    private var menuBarTitle: String {
        if let angle = reader.angle {
            return "\(angle)°"
        }

        return "--°"
    }

    private var menuBarStatus: String {
        if let angle = reader.angle {
            return "Lid Angle: \(angle)°"
        }

        return reader.status
    }
}

private struct MenuBarContent: View {
    @ObservedObject var reader: LidAngleReader
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text(statusText)

        Divider()

        Button("Show") {
            if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
                if window.isMiniaturized {
                    window.deminiaturize(nil)
                }

                window.makeKeyAndOrderFront(nil)
            } else {
                openWindow(id: "main")
            }

            NSApp.activate(ignoringOtherApps: true)
        }

        Button("Quit") {
            NSApp.terminate(nil)
        }
    }

    private var statusText: String {
        if let angle = reader.angle {
            return "Lid Angle: \(angle)°"
        }

        return reader.status
    }
}
