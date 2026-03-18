import SwiftUI
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        print("🚀 [AppDelegate] Initializing Google Mobile Ads SDK...")
        #endif
        
        // Initialisation du SDK AdMob
        MobileAds.shared.start { initStatus in
            #if DEBUG
            print("✅ [AppDelegate] AdMob SDK initialized")
            print("   Adapter statuses:")
            for (adapterName, adapterStatus) in initStatus.adapterStatusesByClassName {
                print("   - \(adapterName): \(adapterStatus.state.rawValue)")
                if adapterStatus.state == .notReady {
                    print("     Description: \(adapterStatus.description)")
                }
            }
            #endif
        }
        
        return true
    }
}

@main
struct UniversalScoreboardApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var viewModel = GameViewModel()
    @StateObject private var adManager = AdManager.shared

    init() {
        // ÉTAPE 1 : Migration (avant tout le reste)
        MigrationManager.migrateV1toV2()
        
        #if DEBUG
        print("🚀 [App] Initialisation des managers...")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(viewModel)
                .onAppear {
                    // ÉTAPE 2 : Reset badge notifications
                    NotificationManager.shared.resetBadge()
                    
                    // ÉTAPE 3 : Check et update streak
                    DailyStreakManager.shared.checkAndUpdateStreak()
                    
                    // ÉTAPE 4 : Demander permission notifs (si 2e lancement)
                    Task {
                        await requestNotificationPermissionIfNeeded()
                    }
                    
                    // ÉTAPE 5 : Scheduler notifs quotidiennes (si pas Bundle)
                    if !StoreManager.shared.hasAllPacksBundle {
                        NotificationManager.shared.scheduleDailyMysteryNotifications()
                    }
                    
                    // ÉTAPE 6 : Précharger pubs
                    AdManager.shared.preloadAds()
                    
                    #if DEBUG
                    print("✅ [App] Managers initialisés")
                    DailyStreakManager.shared.printStatus()
                    UnlockProgressManager.shared.printStatus()
                    #endif
                }
                .fullScreenCover(isPresented: $adManager.showFakeAd) {
                    FakeAdView(
                        isPresented: $adManager.showFakeAd,
                        duration: adManager.fakeAdDuration,
                        onComplete: {
                            adManager.fakeAdCompletion?()
                            adManager.fakeAdCompletion = nil
                        }
                    )
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
