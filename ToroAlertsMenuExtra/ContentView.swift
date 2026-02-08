//
//  ContentView.swift
//  ToroAlertsMenuExtra
//
//  Created by digdog on 2/6/26.
//

import SwiftUI
import ToroAlerts

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            ConnectionStatusView()
            Divider()
            SideIndicatorsView()
            TypingSpeedView()
            Divider()
            PermissionStatusView()
        }
        .padding(20)
        .frame(width: 300)
    }
}

// MARK: - Connection Status

/// Observation scope: isConnected, connectionError only.
private struct ConnectionStatusView: View {
    @Environment(KeyboardMonitor.self) var monitor

    var body: some View {
        if monitor.isConnected {
            Label("Device Connected", systemImage: "cable.connector")
                .font(.callout)
                .foregroundStyle(.green)
        } else if let error = monitor.connectionError {
            VStack(spacing: 8) {
                Label("Device Disconnected", systemImage: "cable.connector.slash")
                    .font(.callout)
                    .foregroundStyle(.red)
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Reconnect") {
                    monitor.connect()
                }
                .buttonStyle(.link)
            }
        } else {
            HStack(spacing: 6) {
                ProgressView()
                    .controlSize(.small)
                Text("Connecting...")
                    .font(.callout)
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - Side Indicators

/// Container only — no observation dependencies.
private struct SideIndicatorsView: View {
    var body: some View {
        HStack(spacing: 30) {
            LeftIndicatorView()
            RightIndicatorView()
        }
    }
}

/// Observation scope: leftActive only.
private struct LeftIndicatorView: View {
    @Environment(KeyboardMonitor.self) var monitor

    var body: some View {
        SideIndicator(label: "Left", isActive: monitor.leftActive, color: .green)
    }
}

/// Observation scope: rightActive only.
private struct RightIndicatorView: View {
    @Environment(KeyboardMonitor.self) var monitor

    var body: some View {
        SideIndicator(label: "Right", isActive: monitor.rightActive, color: .blue)
    }
}

private struct SideIndicator: View {
    let label: String
    let isActive: Bool
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? color : Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isActive ? color : Color.gray.opacity(0.4), lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.1), value: isActive)

            Text(label)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Typing Speed

/// Separate observation scope: only invalidated by typingInterval/typingSpeed changes.
private struct TypingSpeedView: View {
    @Environment(KeyboardMonitor.self) var monitor

    var body: some View {
        VStack(spacing: 4) {
            Text("Typing Speed")
                .font(.caption)
                .foregroundStyle(.secondary)

            if monitor.typingInterval > 0 {
                Text(String(format: "%.0f ms", monitor.typingInterval))
                    .font(.system(.title, design: .monospaced))
                    .bold()
                    .contentTransition(.numericText())
                Text(String(format: "%.1f keys/sec", monitor.typingSpeed))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            } else {
                Text("--")
                    .font(.system(.title, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Permission Status

/// Observation scope: isMonitoring only.
private struct PermissionStatusView: View {
    @Environment(KeyboardMonitor.self) var monitor

    var body: some View {
        if monitor.isMonitoring {
            Label("Monitoring Active", systemImage: "checkmark.circle.fill")
                .font(.callout)
                .foregroundStyle(.green)
        } else {
            VStack(spacing: 8) {
                Text("Input Monitoring Access Required")
                    .font(.callout)
                    .foregroundStyle(.orange)
                Button("Open System Settings") {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.link)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(KeyboardMonitor())
}
