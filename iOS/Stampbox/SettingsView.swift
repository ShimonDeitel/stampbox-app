import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("stampbox_notify_enabled") private var notifyEnabled: Bool = true
    @AppStorage("stampbox_favorites_only") private var favoritesOnly: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable Reminders", isOn: $notifyEnabled)
                        .accessibilityIdentifier("settingsNotifyToggle")
                    Toggle("Show Favorites Only", isOn: $favoritesOnly)
                        .accessibilityIdentifier("settingsFavoritesToggle")
                }

                Section("Subscription") {
                    if purchases.isPro {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundColor(AppTheme.accent)
                    } else {
                        Button("Upgrade to Pro") {}
                            .accessibilityIdentifier("settingsUpgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restorePurchases() }
                    }
                    .accessibilityIdentifier("settingsRestoreButton")
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/stampbox-app/privacy.html")!)
                        .accessibilityIdentifier("settingsPrivacyLink")
                    Text("Contact: s0533495227@gmail.com")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.mutedText)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
