//
//  HomeTabView.swift
//  Crypto
//
//  Created by CJ on 7/13/23.
//

import SwiftUI
import SwiftData

/// A view representing a tab view with three tabs: "Home," "Market," and "Portfolio."
struct HomeTabView: View {
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var selection: Tab = .market
    @Query private var users: [UserProfile]
    @Environment(\.modelContext) var context
    
    /// An enumeration representing the available tabs in the tab view.
    enum Tab: String {
        case watchlist
        case market
        case portfolio
        
        var title: String {
            rawValue.capitalized
        }
    }
    
    var body: some View {
        let user = users.first { $0.email == authService.user?.email } ?? UserProfile(email: "")
        TabView(selection: $selection) {
            WatchlistView(user: user)
                .tabItem {
                    Label("Watchlist", systemImage: "heart")
                }
                .tag(Tab.watchlist)
            MarketView(user: user)
                .tabItem {
                    Label("Market", systemImage: "network")
                }
                .tag(Tab.market)
            PortfolioView(user: user)
                .tabItem {
                    Label("Portfolio", systemImage: "person")
                }
                .tag(Tab.portfolio)
        }
        .task {
            await coinManager.fetchCoinData()
            await portfolioManager.fetchPortfolio(documentID: authService.user?.uid ?? "")
        }
    }
}
