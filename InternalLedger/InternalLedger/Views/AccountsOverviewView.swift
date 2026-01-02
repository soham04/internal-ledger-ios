import SwiftUI

struct AccountsOverviewView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddAccount = false
    
    private var totalBalance: Double {
        appState.accounts.reduce(0) { $0 + $1.balance }
    }
    
    private var activeAccountsCount: Int {
        appState.accounts.filter { $0.status == .active }.count
    }
    
    var body: some View {
        MobileLayout {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    PageHeader(title: "Accounts")
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            if appState.isLoading && appState.accounts.isEmpty {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            } else if let errorMessage = appState.errorMessage {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 48))
                                        .foregroundColor(.red)
                                    Text("Error loading accounts")
                                        .font(.headline)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    Button("Retry") {
                                        Task {
                                            await appState.loadAccounts()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding()
                            } else {
                                // Summary Card
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Balance")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    
                                    Text(Formatters.formatCurrency(totalBalance))
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("\(activeAccountsCount) active accounts")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                // Account List
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("All Accounts")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                    
                                    if appState.accounts.isEmpty {
                                        VStack(spacing: 12) {
                                            Image(systemName: "tray")
                                                .font(.system(size: 48))
                                                .foregroundColor(.secondary)
                                            Text("No accounts yet")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            Text("Tap the + button to add your first account")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 48)
                                    } else {
                                        ForEach(appState.accounts) { account in
                                            NavigationLink(destination: AccountDetailView(accountId: account.id)
                                                .environmentObject(appState)) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        HStack(spacing: 8) {
                                                            Text(account.name)
                                                                .font(.system(size: 16, weight: .medium))
                                                                .foregroundColor(.primary)
                                                            
                                                            StatusBadge(status: account.status)
                                                        }
                                                        
                                                        Text(Formatters.formatCurrency(account.balance))
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.primary)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(16)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(12)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                        }
                    }
                    .refreshable {
                        await appState.loadAccounts()
                    }
                }
                
                FloatingButton(label: "Add Account") {
                    showingAddAccount = true
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AccountFormView(accountId: nil)
                .environmentObject(appState)
        }
    }
}

