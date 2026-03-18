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

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(viewModel)
                .onAppear {
                    AdManager.shared.preloadAds()
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
}
