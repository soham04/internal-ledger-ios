import SwiftUI

struct StatusBadge: View {
    let status: AccountStatus
    
    private var config: (label: String, color: Color, backgroundColor: Color) {
        switch status {
        case .active:
            return ("Active", .green, Color.green.opacity(0.1))
        case .inactive:
            return ("Inactive", .gray, Color.gray.opacity(0.1))
        case .pending:
            return ("Pending", .blue, Color.blue.opacity(0.1))
        }
    }
    
    var body: some View {
        Text(config.label)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(config.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(config.backgroundColor)
            .cornerRadius(6)
    }
}

