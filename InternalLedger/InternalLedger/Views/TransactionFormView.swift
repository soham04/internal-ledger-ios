import SwiftUI

struct TransactionFormView: View {
    let accountId: String
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var type: TransactionType = .credit
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            MobileLayout {
                VStack(spacing: 0) {
                    PageHeader(title: "New Transaction", showBack: true)
                    
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amount")
                                    .font(.system(size: 14, weight: .medium))
                                
                                HStack {
                                    Text("$")
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.00", text: $amount)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.plain)
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Transaction Type")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Picker("Type", selection: $type) {
                                    ForEach(TransactionType.allCases, id: \.self) { type in
                                        Text(type.rawValue.capitalized).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 14, weight: .medium))
                                
                                TextField("Enter transaction description", text: $description)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .font(.system(size: 14, weight: .medium))
                                
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.compact)
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
                                    Text("Save Transaction")
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
        .alert("Validation Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleSubmit() async {
        guard let amountValue = Double(amount), amountValue > 0 else {
            await MainActor.run {
                errorMessage = "Please enter a valid amount"
                showingError = true
            }
            return
        }
        
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                errorMessage = "Description is required"
                showingError = true
            }
            return
        }
        
        await MainActor.run {
            isSubmitting = true
        }
        
        do {
            // API will generate the ID
            let newTransaction = Transaction(
                id: "",
                accountId: accountId,
                description: description,
                amount: amountValue,
                type: type,
                date: date
            )
            
            try await appState.addTransaction(newTransaction)
            
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

