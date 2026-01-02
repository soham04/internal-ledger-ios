import SwiftUI

struct AccountFormView: View {
    let accountId: String?
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var status: AccountStatus = .active
    @State private var balance: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    
    private var isEditing: Bool {
        accountId != nil && accountId != "new"
    }
    
    private var existingAccount: Account? {
        guard let accountId = accountId, isEditing else { return nil }
        return appState.getAccount(by: accountId)
    }
    
    init(accountId: String?) {
        self.accountId = accountId
    }
    
    var body: some View {
        NavigationView {
            MobileLayout {
                VStack(spacing: 0) {
                    PageHeader(
                        title: isEditing ? "Edit Account" : "New Account",
                        showBack: true
                    )
                    
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Account Name")
                                    .font(.system(size: 14, weight: .medium))
                                
                                TextField("Enter account name", text: $name)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Picker("Status", selection: $status) {
                                    ForEach(AccountStatus.allCases, id: \.self) { status in
                                        Text(status.rawValue.capitalized).tag(status)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Balance")
                                    .font(.system(size: 14, weight: .medium))
                                
                                HStack {
                                    Text("$")
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.00", text: $balance)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.plain)
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Section {
                            Button(action: {
                                Task {
                                    await handleSubmit()
                                }
                            }) {
                                HStack {
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text(isEditing ? "Save Changes" : "Create Account")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                                .background(isSubmitting ? Color.gray : Color.blue)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isSubmitting)
                        }
                    }
                    .formStyle(.grouped)
                }
            }
        }
        .onAppear {
            if let account = existingAccount {
                name = account.name
                status = account.status
                balance = String(format: "%.2f", account.balance)
            }
        }
        .alert("Validation Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleSubmit() async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                errorMessage = "Account name is required"
                showingError = true
            }
            return
        }
        
        guard let balanceValue = Double(balance), balanceValue >= 0 else {
            await MainActor.run {
                errorMessage = "Please enter a valid balance"
                showingError = true
            }
            return
        }
        
        await MainActor.run {
            isSubmitting = true
        }
        
        do {
            if isEditing, let accountId = accountId, var updatedAccount = existingAccount {
                updatedAccount.name = name
                updatedAccount.status = status
                updatedAccount.balance = balanceValue
                updatedAccount.lastUpdated = Date()
                try await appState.updateAccount(updatedAccount)
            } else {
                // For new accounts, the API will generate the ID
                let newAccount = Account(
                    id: "", // API will generate this
                    name: name,
                    status: status,
                    balance: balanceValue,
                    lastUpdated: Date()
                )
                try await appState.addAccount(newAccount)
            }
            
            await MainActor.run {
                isSubmitting = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                isSubmitting = false
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

