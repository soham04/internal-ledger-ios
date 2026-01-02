import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadAccounts()
        }
    }
    
    // MARK: - Accounts
    
    func loadAccounts() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedAccounts = try await apiService.fetchAccounts()
            await MainActor.run {
                accounts = fetchedAccounts
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
                print("Error loading accounts: \(error)")
            }
        }
    }
    
    func getAccount(by id: String) -> Account? {
        accounts.first { $0.id == id }
    }
    
    func addAccount(_ account: Account) async throws {
        let createdAccount = try await apiService.createAccount(account)
        await MainActor.run {
            accounts.append(createdAccount)
        }
    }
    
    func updateAccount(_ account: Account) async throws {
        try await apiService.updateAccount(account)
        await MainActor.run {
            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                accounts[index] = account
            }
        }
    }
    
    func deleteAccount(id: String) async throws {
        try await apiService.deleteAccount(id: id)
        await MainActor.run {
            accounts.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Transactions
    
    func loadTransactions(for accountId: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedTransactions = try await apiService.fetchTransactions(accountId: accountId)
            await MainActor.run {
                // Update transactions for this account
                transactions.removeAll { $0.accountId == accountId }
                transactions.append(contentsOf: fetchedTransactions)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
                print("Error loading transactions: \(error)")
            }
        }
    }
    
    func getTransactions(for accountId: String) -> [Transaction] {
        transactions.filter { $0.accountId == accountId }
    }
    
    func addTransaction(_ transaction: Transaction) async throws {
        let createdTransaction = try await apiService.createTransaction(transaction)
        await MainActor.run {
            transactions.append(createdTransaction)
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        try await apiService.updateTransaction(transaction)
        await MainActor.run {
            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                transactions[index] = transaction
            }
        }
    }
    
    func deleteTransaction(id: String) async throws {
        try await apiService.deleteTransaction(id: id)
        await MainActor.run {
            transactions.removeAll { $0.id == id }
        }
    }
}

