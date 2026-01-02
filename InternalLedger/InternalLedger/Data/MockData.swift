import Foundation

struct MockData {
    static let accounts: [Account] = [
        Account(
            id: "ACC-001",
            name: "Operating Account",
            status: .active,
            balance: 1250000.00,
            lastUpdated: Date(timeIntervalSince1970: 1735576200) // 2024-12-30T14:30:00
        ),
        Account(
            id: "ACC-002",
            name: "Payroll Reserve",
            status: .active,
            balance: 485000.00,
            lastUpdated: Date(timeIntervalSince1970: 1735485300) // 2024-12-29T09:15:00
        ),
        Account(
            id: "ACC-003",
            name: "Tax Holdings",
            status: .active,
            balance: 125750.00,
            lastUpdated: Date(timeIntervalSince1970: 1735399500) // 2024-12-28T16:45:00
        ),
        Account(
            id: "ACC-004",
            name: "Capital Reserve",
            status: .inactive,
            balance: 0,
            lastUpdated: Date(timeIntervalSince1970: 1734282000) // 2024-11-15T11:00:00
        ),
        Account(
            id: "ACC-005",
            name: "Vendor Payments",
            status: .pending,
            balance: 89500.00,
            lastUpdated: Date(timeIntervalSince1970: 1735560000) // 2024-12-30T08:00:00
        )
    ]
    
    static let transactions: [Transaction] = [
        Transaction(
            id: "TXN-001",
            accountId: "ACC-001",
            description: "Client Payment - Acme Corp",
            amount: 45000.00,
            type: .credit,
            date: Date(timeIntervalSince1970: 1735564200) // 2024-12-30T10:30:00
        ),
        Transaction(
            id: "TXN-002",
            accountId: "ACC-001",
            description: "Office Lease - Q1 2025",
            amount: 15000.00,
            type: .debit,
            date: Date(timeIntervalSince1970: 1735477200) // 2024-12-29T14:00:00
        ),
        Transaction(
            id: "TXN-003",
            accountId: "ACC-001",
            description: "Software Licenses",
            amount: 2500.00,
            type: .debit,
            date: Date(timeIntervalSince1970: 1735390500) // 2024-12-28T09:15:00
        ),
        Transaction(
            id: "TXN-004",
            accountId: "ACC-001",
            description: "Investment Return",
            amount: 12500.00,
            type: .credit,
            date: Date(timeIntervalSince1970: 1735305000) // 2024-12-27T16:30:00
        ),
        Transaction(
            id: "TXN-005",
            accountId: "ACC-001",
            description: "Equipment Purchase",
            amount: 8750.00,
            type: .debit,
            date: Date(timeIntervalSince1970: 1735218000) // 2024-12-26T11:00:00
        ),
        Transaction(
            id: "TXN-006",
            accountId: "ACC-002",
            description: "Monthly Payroll",
            amount: 125000.00,
            type: .debit,
            date: Date(timeIntervalSince1970: 1735084800) // 2024-12-25T00:00:00
        ),
        Transaction(
            id: "TXN-007",
            accountId: "ACC-002",
            description: "Payroll Funding",
            amount: 150000.00,
            type: .credit,
            date: Date(timeIntervalSince1970: 1735020000) // 2024-12-24T09:00:00
        )
    ]
}

