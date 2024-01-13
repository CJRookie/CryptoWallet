//
//  CoinManager.swift
//  Crypto
//
//  Created by CJ on 7/13/23.
//

import Foundation

final class CoinManager: ObservableObject {
    @Published private(set) var coins: [Coin] = []
    @Published private(set) var coinDic: [String: Coin] = [:]
    @Published private(set) var top10MovingCoins: [Coin] = []
    @Published private(set) var errorMessage: String = ""
    private let url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=true"
    
    func fetchCoinData() async {
        do {
            let data = try await APIService.downloadData(from: url)
            try await MainActor.run {
                coins = try JSONDecoder().decode([Coin].self, from: data)
                top10MovingCoins = getTop10Movers()
                coinDic = mapCoinDic()
            }
        } catch {
            errorMessage = error.localizedDescription
            print(error.localizedDescription)
        }
    }
    
    private func mapCoinDic() -> [String: Coin] {
        coins.reduce(into: [String: Coin]()) { $0[$1.nameString] = $1 }
    }
    
    private func getTop10Movers() -> [Coin] {
        Array(coins.sorted { abs($0.priceChangePercentage24HDouble) > abs($1.priceChangePercentage24HDouble) }.prefix(10))
    }
}
