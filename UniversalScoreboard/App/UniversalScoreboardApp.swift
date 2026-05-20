import SwiftUI

@main
struct UniversalScoreboardApp: App {

    @StateObject private var viewModel = GameViewModel()

    init() {
        #if DEBUG
        print("🚀 [App] Initialisation - Version 6.0.0 (100% gratuite)")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(viewModel)
                .onAppear {
                    // ÉTAPE 2 : Reset badge notifications
                    NotificationManager.shared.resetBadge()
                    
                    // ÉTAPE 3 : Demander permission notifs (si 2e lancement)
                    Task {
                        await requestNotificationPermissionIfNeeded()
                    }
                    
                    #if DEBUG
                    print("✅ [App] Managers initialisés")
                    #endif
                }
        }
    }
    
    // MARK: - Helpers
    
    /// Demande permission notifications au 2e lancement
    private func requestNotificationPermissionIfNeeded() async {
        let defaults = UserDefaults.standard
        let launchCount = defaults.integer(forKey: "app.launchCount") + 1
        defaults.set(launchCount, forKey: "app.launchCount")
        
        let hasAsked = defaults.bool(forKey: "notif.permissionAsked")
        
        // Demander au 2e lancement (meilleur taux d'acceptation)
        if launchCount == 2 && !hasAsked {
            await NotificationManager.shared.requestPermission()
            defaults.set(true, forKey: "notif.permissionAsked")
            
            #if DEBUG
            print("✅ [App] Permission notifications demandée (2e lancement)")
            #endif
        }
    }
}
