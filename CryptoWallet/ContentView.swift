//
//  ContentView.swift
//  CryptoWallet
//
//  Created by CJ on 7/7/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        switch authService.authState {
        case .authenticating:
            TransitionView()
        case .unauthenticated:
            LoginView()
        case .authenticated:
            HomeTabView()
        }
    }
}
