//
//  ToroAlertsMenuExtraApp.swift
//  ToroAlertsMenuExtra
//
//  Created by digdog on 2/6/26.
//

import SwiftUI
import ToroAlerts

@main
struct ToroAlertsMenuExtraApp: App {
    @State private var isActivated = false
    @State private var bridgeTask: Task<Void, Never>?
    @State private var keyboardMonitor = KeyboardMonitor()
    @State private var coordinator = DeviceCoordinator()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra("Toro Alerts", image: isActivated ? "ToroOn" : "ToroOff") {
            Toggle("學人精！機械鍵盤模擬器", isOn: $isActivated)
            Divider()
            Button("除錯專用視窗") {
                openWindow(id: "keyboardMonitor")
            }
            Divider()
            Button("結束") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .onChange(of: isActivated) { _, newValue in
            if newValue {
                bridgeTask = Task { await startBridge() }
            } else {
                bridgeTask?.cancel()
                bridgeTask = nil
                keyboardMonitor.stop()
                coordinator.finish()
            }
        }

        Window("Keyboard Monitor", id: "keyboardMonitor") {
            ContentView()
                .environment(keyboardMonitor)
        }
        .windowResizability(.contentSize)
    }

    private func startBridge() async {
        keyboardMonitor.start()
        coordinator.start()

        let keyStream = keyboardMonitor.newEventStream()
        let deviceStream = coordinator.newEventStream()
        let coordinator = coordinator
        let keyboardMonitor = keyboardMonitor

        await withTaskGroup(of: Void.self) { group in
            // Keyboard → Device
            group.addTask {
                for await event in keyStream {
                    switch event {
                    case .deviceAction(let request, let interval):
                        coordinator.yield(request, interval: interval)
                    case .reconnectRequested:
                        coordinator.start()
                    }
                }
            }

            // Device → UI
            group.addTask {
                for await event in deviceStream {
                    await MainActor.run {
                        switch event {
                        case .connected:
                            keyboardMonitor.isConnected = true
                            keyboardMonitor.connectionError = nil
                        case .disconnected:
                            keyboardMonitor.isConnected = false
                        case .sendFailed(let error):
                            keyboardMonitor.connectionError = error.description
                        }
                    }
                }
            }
        }
    }
}
