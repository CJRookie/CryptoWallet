//
//  MarketView.swift
//  Crypto
//
//  Created by CJ on 7/13/23.
//

import SwiftUI

/// A view that displays a searchable market view with a menu bar and a list of coins.
struct MarketView: View {
    @EnvironmentObject var manager: CoinManager
    @State private var menuItem: CoinMenuItem = .cryptos
    @State private var sortOption: SortOption = .marketCapRank
    @State private var isDescending = true
    @State private var searchText = ""
    @State private var refreshableTask: Task<(), Error>?
    @Bindable var user: UserProfile
    
    var updatedCoins: [Coin] {
        CoinListOperation.update(manager.coins, item: menuItem, option: sortOption, isDescending: isDescending, text: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                MenuBar(selectedItem: $menuItem)
                SortSelection(selectedOption: $sortOption, isDescending: $isDescending)
                CoinList(coins: updatedCoins, user: user)
            }
            .navigationTitle("Market")
        }
        .searchable(text: $searchText, prompt: Text("Search by Name/Symbol"))
        .refreshable {
            executeRefreshableTask()
        }
        .onDisappear {
            refreshableTask?.cancel()
        }
    }
    
    private func executeRefreshableTask() {
        refreshableTask?.cancel()
        refreshableTask = Task {
            await manager.fetchCoinData()
        }
    }
}
