import SwiftUI

struct NotFoundView: View {
    var body: some View {
        MobileLayout {
            VStack(spacing: 0) {
                PageHeader(title: "404", showBack: true)
                
                VStack(spacing: 16) {
                    Spacer()
                    
                    Text("404")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Oops! Page not found")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
}

