import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.accent)
                Text("Stampbox Pro")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.primaryText)
                Text("Unlimited stamps and album-page layout export")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if let product = purchases.products.first {
                    Button {
                        Task {
                            isPurchasing = true
                            await purchases.purchasePro()
                            isPurchasing = false
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        Text(isPurchasing ? "Processing..." : "Unlock for \(product.displayPrice)")
                            .font(AppTheme.headlineFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.accent)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    .accessibilityIdentifier("paywallPurchaseButton")
                    .disabled(isPurchasing)
                    .padding(.horizontal, 32)
                } else {
                    ProgressView().padding()
                }

                Button("Restore Purchases") {
                    Task { await purchases.restorePurchases() }
                }
                .accessibilityIdentifier("paywallRestoreButton")
                .foregroundColor(AppTheme.secondary)

                Spacer()

                Button("Not Now") { dismiss() }
                    .accessibilityIdentifier("paywallDismissButton")
                    .foregroundColor(AppTheme.mutedText)
                    .padding(.bottom, 24)
            }
        }
    }
}
