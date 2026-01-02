import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://ledger-backend-app.azurewebsites.net"
    
    // Custom date formatter for API dates: "2025-12-31T17:30:00" (without timezone)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Assume UTC if no timezone
        return formatter
    }()
    
    private init() {}
    
    // Helper to create decoder with custom date format
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Self.dateFormatter)
        return decoder
    }
    
    // Helper to create encoder with custom date format
    private func createEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Self.dateFormatter)
        return encoder
    }
    
    // MARK: - Accounts API
    
    func fetchAccounts() async throws -> [Account] {
        guard let url = URL(string: "\(baseURL)/accounts") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = createDecoder()
        
        do {
            let accounts = try decoder.decode([Account].self, from: data)
            return accounts
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    func fetchAccount(id: String) async throws -> Account {
        // API expects numeric ID, but we store as string
        // Try to convert, or use as-is if already numeric string
        let numericId = Int(id) ?? 0
        guard let url = URL(string: "\(baseURL)/accounts/\(numericId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = createDecoder()
        
        do {
            let account = try decoder.decode(Account.self, from: data)
            return account
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    func createAccount(_ account: Account) async throws -> Account {
        guard let url = URL(string: "\(baseURL)/accounts") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body without ID (API will generate it)
        // API expects accountName, not name
        let accountDict: [String: Any] = [
            "accountName": account.name,
            "status": account.status.rawValue,
            "balance": account.balance,
            "lastUpdated": Self.dateFormatter.string(from: account.lastUpdated)
        ]
        
        // Encode without ID field
        let bodyData = try JSONSerialization.data(withJSONObject: accountDict)
        request.httpBody = bodyData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = createDecoder()
        
        do {
            let createdAccount = try decoder.decode(Account.self, from: data)
            return createdAccount
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    func updateAccount(_ account: Account) async throws {
        // API expects numeric ID in URL
        guard let numericId = Int(account.id),
              let url = URL(string: "\(baseURL)/accounts/\(numericId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use custom encoding with CodingKeys
        let encoder = createEncoder()
        request.httpBody = try encoder.encode(account)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 204 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
    
    func deleteAccount(id: String) async throws {
        // API expects numeric ID
        guard let numericId = Int(id),
              let url = URL(string: "\(baseURL)/accounts/\(numericId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 204 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Transactions API
    
    func fetchTransactions(accountId: String) async throws -> [Transaction] {
        // API expects numeric accountId
        guard let numericAccountId = Int(accountId),
              let url = URL(string: "\(baseURL)/transactions?accountId=\(numericAccountId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                // 404 means no transactions found - return empty array
                return []
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = createDecoder()
        
        do {
            let transactions = try decoder.decode([Transaction].self, from: data)
            return transactions
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    func fetchTransaction(id: String) async throws -> Transaction {
        // API expects numeric ID
        guard let numericId = Int(id),
              let url = URL(string: "\(baseURL)/transactions/\(numericId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = createDecoder()
        
        do {
            let transaction = try decoder.decode(Transaction.self, from: data)
            return transaction
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        guard let url = URL(string: "\(baseURL)/transactions") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body without ID (API will generate it)
        // API expects numeric accountId and transactionDate field
        guard let numericAccountId = Int(transaction.accountId) else {
            throw APIError.invalidURL
        }
        
        let transactionDict: [String: Any] = [
            "accountId": numericAccountId,
            "description": transaction.description,
            "amount": transaction.amount,
            "type": transaction.type.rawValue,
            "transactionDate": Self.dateFormatter.string(from: transaction.date)
        ]
        
        let bodyData = try JSONSerialization.data(withJSONObject: transactionDict)
        request.httpBody = bodyData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            if httpResponse.statusCode == 400 {
                throw APIError.badRequest("Account doesn't exist")
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = createDecoder()
        
        do {
            let createdTransaction = try decoder.decode(Transaction.self, from: data)
            return createdTransaction
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            throw APIError.decodingError(error)
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        // API expects numeric ID
        guard let numericId = Int(transaction.id),
              let url = URL(string: "\(baseURL)/transactions/\(numericId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = createEncoder()
        request.httpBody = try encoder.encode(transaction)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 204 else {
            if httpResponse.statusCode == 400 {
                throw APIError.badRequest("Account doesn't exist")
            }
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
    
    func deleteTransaction(id: String) async throws {
        // API expects numeric ID
        guard let numericId = Int(id),
              let url = URL(string: "\(baseURL)/transactions/\(numericId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 204 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case notFound
    case badRequest(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .notFound:
            return "Resource not found"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

