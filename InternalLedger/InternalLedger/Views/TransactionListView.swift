import SwiftUI

struct TransactionListView: View {
    let accountId: String
    @EnvironmentObject var appState: AppState
    @State private var showingAddTransaction = false
    
    private var account: Account? {
        appState.getAccount(by: accountId)
    }
    
    private var transactions: [Transaction] {
        appState.getTransactions(for: accountId)
    }
    
    private var totalCredits: Double {
        transactions
            .filter { $0.type == .credit }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalDebits: Double {
        transactions
            .filter { $0.type == .debit }
            .reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        Group {
            if let account = account {
                MobileLayout {
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 0) {
                            PageHeader(title: "Transactions", showBack: true)
                            
                            ScrollView {
                                if appState.isLoading && transactions.isEmpty {
                                    ProgressView()
                                        .padding()
                                } else {
                                    VStack(spacing: 16) {
                                        // Summary Card
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text(account.name)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                            
                                            HStack(spacing: 16) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Credits")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                    Text(Formatters.formatCurrency(totalCredits))
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.primary)
                                                }
                                                
                                                Rectangle()
                                                    .frame(width: 1, height: 40)
                                                    .foregroundColor(Color(.separator))
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Debits")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                    Text(Formatters.formatCurrency(totalDebits))
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)
                                        
                                        // Transaction List
                                        if transactions.isEmpty {
                                            VStack(spacing: 12) {
                                                Image(systemName: "list.bullet")
                                                    .font(.system(size: 48))
                                                    .foregroundColor(.secondary)
                                                Text("No transactions yet")
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)
                                                Text("Tap the + button to add your first transaction")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 48)
                                        } else {
                                            VStack(spacing: 8) {
                                                ForEach(transactions) { transaction in
                                                    HStack(spacing: 12) {
                                                        // Icon
                                                        Image(systemName: transaction.type == .credit ? "arrow.down.left" : "arrow.up.right")
                                                            .font(.system(size: 16))
                                                            .foregroundColor(transaction.type == .credit ? .secondary : .red)
                                                            .frame(width: 32, height: 32)
                                                            .background(
                                                                transaction.type == .credit
                                                                    ? Color(.secondarySystemBackground)
                                                                    : Color.red.opacity(0.1)
                                                            )
                                                            .cornerRadius(8)
                                                        
                                                        // Description and Date
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(transaction.description)
                                                                .font(.system(size: 16, weight: .medium))
                                                                .foregroundColor(.primary)
                                                                .lineLimit(1)
                                                            
                                                            Text(Formatters.formatShortDate(transaction.date))
                                                                .font(.system(size: 14))
                                                                .foregroundColor(.secondary)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        // Amount
                                                        Text("\(transaction.type == .debit ? "-" : "+")\(Formatters.formatCurrency(transaction.amount))")
                                                            .font(.system(size: 16, weight: .semibold))
                                                            .foregroundColor(transaction.type == .debit ? .red : .primary)
                                                    }
                                                    .padding(16)
                                                    .background(Color(.secondarySystemBackground))
                                                    .cornerRadius(12)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                    .padding(.bottom, 100)
                                }
                            }
                            .refreshable {
                                await appState.loadTransactions(for: accountId)
                            }
                        }
                        
                        FloatingButton(label: "Add Transaction") {
                            showingAddTransaction = true
                        }
                    }
                }
                .sheet(isPresented: $showingAddTransaction) {
                    TransactionFormView(accountId: accountId)
                        .environmentObject(appState)
                }
                .onAppear {
                    Task {
                        await appState.loadTransactions(for: accountId)
                    }
                }
            } else {
                MobileLayout {
                    VStack(spacing: 0) {
                        PageHeader(title: "Transactions", showBack: true)
                        
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

