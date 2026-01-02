import SwiftUI

struct AccountDetailView: View {
    let accountId: String
    @EnvironmentObject var appState: AppState
    @State private var showingEdit = false
    
    private var account: Account? {
        appState.getAccount(by: accountId)
    }
    
    var body: some View {
        Group {
            if let account = account {
                MobileLayout {
                    VStack(spacing: 0) {
                        PageHeader(
                            title: "Account",
                            showBack: true
                        ) {
                            Button(action: { showingEdit = true }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                                    .padding(8)
                            }
                        }
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                // Account Header Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Text(account.name)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        StatusBadge(status: account.status)
                                    }
                                    
                                    Text(Formatters.formatCurrency(account.balance))
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .padding(.top, 8)
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Account ID")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            Text(account.id)
                                                .font(.system(size: 14, design: .monospaced))
                                                .foregroundColor(.primary)
                                        }
                                        
                                        Rectangle()
                                            .frame(width: 1, height: 32)
                                            .foregroundColor(Color(.separator))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Last Updated")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            Text(Formatters.formatDateTime(account.lastUpdated))
                                                .font(.system(size: 14))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(20)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                // Action Button
                                NavigationLink(destination: TransactionListView(accountId: accountId)
                                    .environmentObject(appState)) {
                                    HStack {
                                        Text("View Transactions")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 20))
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingEdit) {
                    AccountFormView(accountId: accountId)
                        .environmentObject(appState)
                }
            } else {
                MobileLayout {
                    VStack(spacing: 0) {
                        PageHeader(title: "Account", showBack: true)
                        
                        VStack {
                            Spacer()
                            Text("Account not found")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

