//
//  ContentView.swift
//  LidSense
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var reader: LidAngleReader

    var body: some View {
        TabView {
            LidAngleView(reader: reader)
                .tabItem {
                    Text("Lid Angle")
                }

            SettingsView()
                .tabItem {
                    Text("Settings")
                }
        }
        .frame(minWidth: 360, minHeight: 240)
    }
}

private struct LidAngleView: View {
    @ObservedObject var reader: LidAngleReader

    var body: some View {
        VStack(spacing: 18) {
            Text("Lid Angle")
                .font(.title2)
                .fontWeight(.semibold)

            if let angle = reader.angle {
                Text("\(angle)°")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .accessibilityLabel("Current lid angle")
                    .accessibilityValue("\(angle) degrees")
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "laptopcomputer.trianglebadge.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)

                    Text("Unavailable")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text(reader.status)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }

            Text(reader.status)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
    }
}

private struct SettingsView: View {
    @AppStorage("showInMenuBar") private var showInMenuBar = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            Toggle("Show in Menu Bar", isOn: $showInMenuBar)
                .toggleStyle(.switch)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
    }
}
