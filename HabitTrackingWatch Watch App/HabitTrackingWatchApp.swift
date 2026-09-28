//
//  HabitTrackingWatchApp.swift
//  HabitTrackingWatch Watch App
//
//  Created by Felipe Morais on 17/01/25.
//

import SwiftUI

@main
struct HabitTrackingWatch_Watch_AppApp: App {
    @StateObject private var dataStore = HabitDataStore()
    @StateObject private var watchConnector = WatchConnector()

    var body: some Scene {
        WindowGroup {
            WatchHabitsTodayView()
                .environmentObject(dataStore)
                .onAppear {
                    watchConnector.habitDataStore = dataStore
                }
        }
    }
}
