//
//  CryptoWalletApp.swift
//  CryptoWallet
//
//  Created by CJ on 7/7/23.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct CryptoWalletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = FirebaseAuthService()
    @StateObject private var coinManager = CoinManager()
    @StateObject private var portfolioManager = PortfolioManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(coinManager)
                .environmentObject(portfolioManager)
                .modelContainer(for: [UserProfile.self, FavoriteCoin.self])
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      return true
  }
}
