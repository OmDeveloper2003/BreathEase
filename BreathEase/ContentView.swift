//
//  ContentView.swift
//  BreathEase
//
//  Created by Om's M2 on 19/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Breathe", systemImage: "lungs.fill")
                }
                .tag(0)
            
            ExercisesView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.mind.and.body")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.xyaxis.line")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
