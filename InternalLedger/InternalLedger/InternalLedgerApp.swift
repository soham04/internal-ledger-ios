//
//  InternalLedgerApp.swift
//  InternalLedger
//
//  Created by Soham Shinde on 12/31/25.
//

import SwiftUI

@main
struct InternalLedgerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AccountsOverviewView()
                    .environmentObject(appState)
            }
            .navigationViewStyle(.stack)
        }
    }
}
