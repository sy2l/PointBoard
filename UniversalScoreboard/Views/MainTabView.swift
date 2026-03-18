/*
 MainTabView.swift
 PointBoard

 Vue principale avec navigation par onglets.
 Sprint 0 - V3.0
 */

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                SetupView()
            }
            .tabItem {
                Label("Jouer", systemImage: "gamecontroller.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Historique", systemImage: "clock.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Réglages", systemImage: "gearshape.fill")
            }
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(Color.appBackground)
        }
        .tint(.appPrimary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(GameViewModel())
}
