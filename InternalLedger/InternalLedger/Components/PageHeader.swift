import SwiftUI

struct PageHeader: View {
    let title: String
    let showBack: Bool
    let rightAction: AnyView?
    @Environment(\.dismiss) var dismiss
    
    init(title: String, showBack: Bool = false) {
        self.title = title
        self.showBack = showBack
        self.rightAction = nil
    }
    
    init<Content: View>(title: String, showBack: Bool = false, @ViewBuilder rightAction: () -> Content) {
        self.title = title
        self.showBack = showBack
        self.rightAction = AnyView(rightAction())
    }
    
    var body: some View {
        HStack {
            if showBack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if let rightAction = rightAction {
                rightAction
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.95))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

