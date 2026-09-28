//
//  ContentView.swift
//  HabitTrackingWatch Watch App
//
//  Created by Felipe Morais on 17/01/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        WatchHabitsTodayView()
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitDataStore.sampleDataStore)
}
