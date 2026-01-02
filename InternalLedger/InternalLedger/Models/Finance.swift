import Foundation

enum AccountStatus: String, Codable, CaseIterable {
    case active = "Active"
    case inactive = "Inactive"
    case pending = "Pending"
    
    // Custom decoding to handle both capitalized and lowercase
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try to match with rawValue first (capitalized)
        if let status = AccountStatus(rawValue: rawValue) {
            self = status
            return
        }
        
        // Fallback to lowercase matching
        switch rawValue.lowercased() {
        case "active":
            self = .active
        case "inactive":
            self = .inactive
        case "pending":
            self = .pending
        default:
            self = .active // Default fallback
        }
    }
}

struct Account: Identifiable, Codable {
    let id: String
    var name: String
    var status: AccountStatus
    var balance: Double
    var lastUpdated: Date
    
    // API uses accountId (numeric) and accountName
    enum CodingKeys: String, CodingKey {
        case accountId
        case accountName
        case status
        case balance
        case lastUpdated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Convert numeric accountId to string
        let accountIdValue: Int = try container.decode(Int.self, forKey: .accountId)
        id = String(accountIdValue)
        
        name = try container.decode(String.self, forKey: .accountName)
        status = try container.decode(AccountStatus.self, forKey: .status)
        balance = try container.decode(Double.self, forKey: .balance)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(id) ?? 0, forKey: .accountId)
        try container.encode(name, forKey: .accountName)
        try container.encode(status, forKey: .status)
        try container.encode(balance, forKey: .balance)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
    
    // Regular initializer for creating accounts in the app
    init(id: String, name: String, status: AccountStatus, balance: Double, lastUpdated: Date) {
        self.id = id
        self.name = name
        self.status = status
        self.balance = balance
        self.lastUpdated = lastUpdated
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case credit = "Credit"
    case debit = "Debit"
    
    // Custom decoding to handle both capitalized and lowercase
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try to match with rawValue first (capitalized)
        if let type = TransactionType(rawValue: rawValue) {
            self = type
            return
        }
        
        // Fallback to lowercase matching
        switch rawValue.lowercased() {
        case "credit":
            self = .credit
        case "debit":
            self = .debit
        default:
            self = .credit // Default fallback
        }
    }
}

struct Transaction: Identifiable, Codable {
    let id: String
    let accountId: String
    var description: String
    var amount: Double
    var type: TransactionType
    var date: Date
    
    // API uses transactionId (numeric), transactionDate, and numeric accountId
    enum CodingKeys: String, CodingKey {
        case transactionId
        case accountId
        case description
        case amount
        case type
        case transactionDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Convert numeric transactionId to string
        let transactionIdValue: Int = try container.decode(Int.self, forKey: .transactionId)
        id = String(transactionIdValue)
        
        // Convert numeric accountId to string
        let accountIdValue: Int = try container.decode(Int.self, forKey: .accountId)
        accountId = String(accountIdValue)
        
        description = try container.decode(String.self, forKey: .description)
        amount = try container.decode(Double.self, forKey: .amount)
        type = try container.decode(TransactionType.self, forKey: .type)
        date = try container.decode(Date.self, forKey: .transactionDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(id) ?? 0, forKey: .transactionId)
        try container.encode(Int(accountId) ?? 0, forKey: .accountId)
        try container.encode(description, forKey: .description)
        try container.encode(amount, forKey: .amount)
        try container.encode(type, forKey: .type)
        try container.encode(date, forKey: .transactionDate)
    }
    
    // Regular initializer for creating transactions in the app
    init(id: String, accountId: String, description: String, amount: Double, type: TransactionType, date: Date) {
        self.id = id
        self.accountId = accountId
        self.description = description
        self.amount = amount
        self.type = type
        self.date = date
    }
}

