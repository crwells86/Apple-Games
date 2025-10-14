import SwiftUI
import StoreKit

// MARK: - IAP: Purchase Manager
@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    // Replace with your real product ID configured in App Store Connect
    let halloweenProductID = "1dDash.halloween.theme"

    // Persisted entitlement
    private let entitlementKey = "entitlement.halloweenTheme"

    var hasHalloweenEntitlement: Bool {
        get { UserDefaults.standard.bool(forKey: entitlementKey) }
        set { UserDefaults.standard.set(newValue, forKey: entitlementKey) }
    }

    // Cached Product
    private(set) var halloweenProduct: Product?
    // Task to listen for transaction updates
    private var updatesListenerTask: Task<Void, Never>?

    private init() {
        Task { @MainActor in
            startListeningForTransactions()
        }
    }

    deinit {
        updatesListenerTask?.cancel()
    }

    @MainActor
    private func startListeningForTransactions() {
        // Cancel existing task if any
        updatesListenerTask?.cancel()

        updatesListenerTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = update {
                    if transaction.productID == self.halloweenProductID {
                        self.hasHalloweenEntitlement = true
                    }
                    await transaction.finish()
                } else {
                    // Ignore unverified transactions
                }
            }
        }
    }

    @MainActor
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [halloweenProductID])
            self.halloweenProduct = products.first
        } catch {
            // Handle product load error if needed
            print("[IAP] Failed to load products: \(error)")
        }
    }

    @MainActor
    func purchaseHalloween() async throws {
        // Ensure product is loaded
        if halloweenProduct == nil {
            await loadProducts()
        }
        guard let product = halloweenProduct else { throw PurchaseError.productUnavailable }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                // Grant entitlement
                hasHalloweenEntitlement = true
                await transaction.finish()
            } else {
                throw PurchaseError.unverified
            }
        case .userCancelled:
            throw PurchaseError.cancelled
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }

    @MainActor
    func restorePurchases() async {
        // Iterate current entitlements
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == halloweenProductID {
                hasHalloweenEntitlement = true
            }
        }
    }

    enum PurchaseError: Error, LocalizedError {
        case productUnavailable, unverified, cancelled, pending, unknown
        var errorDescription: String? {
            switch self {
            case .productUnavailable: return "Product unavailable."
            case .unverified: return "Unable to verify purchase."
            case .cancelled: return "Purchase was cancelled."
            case .pending: return "Purchase is pending."
            case .unknown: return "Unknown purchase error."
            }
        }
    }
}

// MARK: - Theme Model
import SwiftUI

enum GameTheme: String, CaseIterable, Identifiable {
    // Regular themes
    case retro = "Retro"
    case neon = "Neon"
    case nature = "Nature"
    case space = "Space"
    
    // Holiday themes
    case newYear = "New Year"
    case valentines = "Valentine's"
    case stPatricks = "St. Patrick's"
    case easter = "Easter"
    case independence = "Independence"
    case halloween = "Halloween"
    case thanksgiving = "Thanksgiving"
    case christmas = "Christmas"
    
    var id: String { rawValue }
    
    var requiresPurchase: Bool {
        switch self {
        case .halloween:
            return true
        default:
            return false
        }
    }
    
    // Asset names for each theme
    var playerSprites: [String] {
        switch self {
        case .retro: return ["player00", "player01"]
        case .neon: return ["neon_player00", "neon_player01"]
        case .nature: return ["nature_player00", "nature_player01"]
        case .space: return ["space_player00", "space_player01"]
        case .newYear: return ["newyear_player00", "newyear_player01"]
        case .valentines: return ["valentine_player00", "valentine_player01"]
        case .stPatricks: return ["stpatrick_player00", "stpatrick_player01"]
        case .easter: return ["easter_player00", "easter_player01"]
        case .independence: return ["july4_player00", "july4_player01"]
        case .halloween: return ["halloween_player00", "halloween_player01"]
        case .thanksgiving: return ["thanksgiving_player00", "thanksgiving_player01"]
        case .christmas: return ["christmas_player00", "christmas_player01"]
        }
    }
    
    var enemySprites: [String] {
        switch self {
        case .retro: return ["enemy00", "enemy01"]
        case .neon: return ["neon_enemy00", "neon_enemy01"]
        case .nature: return ["nature_enemy00", "nature_enemy01"]
        case .space: return ["space_enemy00", "space_enemy01"]
        case .newYear: return ["newyear_enemy00", "newyear_enemy01"]
        case .valentines: return ["valentine_enemy00", "valentine_enemy01"]
        case .stPatricks: return ["stpatrick_enemy00", "stpatrick_enemy01"]
        case .easter: return ["easter_enemy00", "easter_enemy01"]
        case .independence: return ["july4_enemy00", "july4_enemy01"]
        case .halloween: return ["halloween_enemy00", "halloween_enemy01"]
        case .thanksgiving: return ["thanksgiving_enemy00", "thanksgiving_enemy01"]
        case .christmas: return ["christmas_enemy00", "christmas_enemy01"]
        }
    }
    
    var coinSprites: [String] {
        switch self {
        case .retro: return ["coin00", "coin01", "coin02"]
        case .neon: return ["neon_coin00", "neon_coin01", "neon_coin02"]
        case .nature: return ["nature_coin00", "nature_coin01", "nature_coin02"]
        case .space: return ["space_coin00", "space_coin01", "space_coin02"]
        case .newYear: return ["newyear_coin00", "newyear_coin01", "newyear_coin02"]
        case .valentines: return ["valentine_coin00", "valentine_coin01", "valentine_coin02"]
        case .stPatricks: return ["stpatrick_coin00", "stpatrick_coin01", "stpatrick_coin02"]
        case .easter: return ["easter_coin00", "easter_coin01", "easter_coin02"]
        case .independence: return ["july4_coin00", "july4_coin01", "july4_coin02"]
        case .halloween: return ["halloween_coin00", "halloween_coin01", "halloween_coin02"]
        case .thanksgiving: return ["thanksgiving_coin00", "thanksgiving_coin01", "thanksgiving_coin02"]
        case .christmas: return ["christmas_coin00", "christmas_coin01", "christmas_coin02"]
        }
    }
    
    var platformSprite: String {
        switch self {
        case .retro: return "platform"
        case .neon: return "neon_platform"
        case .nature: return "nature_platform"
        case .space: return "space_platform"
        case .newYear: return "newyear_platform"
        case .valentines: return "valentine_platform"
        case .stPatricks: return "stpatrick_platform"
        case .easter: return "easter_platform"
        case .independence: return "july4_platform"
        case .halloween: return "halloween_platform"
        case .thanksgiving: return "thanksgiving_platform"
        case .christmas: return "christmas_platform"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .retro: return .black
        case .neon: return Color(red: 0.1, green: 0.0, blue: 0.2)
        case .nature: return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .space: return Color(red: 0.05, green: 0.05, blue: 0.15)
        case .newYear: return Color(red: 0.05, green: 0.05, blue: 0.2) // Midnight blue
        case .valentines: return Color(red: 0.9, green: 0.4, blue: 0.5) // Pink
        case .stPatricks: return Color(red: 0.1, green: 0.5, blue: 0.2) // Green
        case .easter: return Color(red: 0.7, green: 0.85, blue: 0.95) // Pastel blue
        case .independence: return Color(red: 0.1, green: 0.15, blue: 0.35) // Navy
        case .halloween: return Color(red: 0.15, green: 0.1, blue: 0.2) // Dark purple
        case .thanksgiving: return Color(red: 0.5, green: 0.3, blue: 0.15) // Brown/orange
        case .christmas: return Color(red: 0.1, green: 0.3, blue: 0.2) // Forest green
        }
    }
    
    var backgroundImage: String? {
        switch self {
        case .retro: return nil
        case .neon: return "neon_background"
        case .nature: return "nature_background"
        case .space: return "space_background"
        case .newYear: return "newyear_background"
        case .valentines: return "valentine_background"
        case .stPatricks: return "stpatrick_background"
        case .easter: return "easter_background"
        case .independence: return "july4_background"
        case .halloween: return "halloween_background"
        case .thanksgiving: return "thanksgiving_background"
        case .christmas: return "christmas_background"
        }
    }
    
    var previewIcon: String {
        // Return first player sprite for preview
        return playerSprites[0]
    }
}

// MARK: - Theme Manager
@Observable class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme: GameTheme = .retro {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = GameTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    func canUse(theme: GameTheme) -> Bool {
        if theme.requiresPurchase {
            return PurchaseManager.shared.hasHalloweenEntitlement
        }
        return true
    }
}

// MARK: - Theme Selection View
struct ThemeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var themeManager = ThemeManager.shared
    @Bindable var purchaseManager = PurchaseManager.shared
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(GameTheme.allCases.filter { $0 == .retro || $0 == .halloween }) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: themeManager.currentTheme == theme,
                                isLocked: theme.requiresPurchase && !themeManager.canUse(theme: theme),
                                priceText: theme == .halloween ? (purchaseManager.halloweenProduct?.displayPrice ?? "$0.99") : nil,
                                onBuy: {
                                    Task { @MainActor in
                                        isPurchasing = true
                                        defer { isPurchasing = false }
                                        do {
                                            try await purchaseManager.purchaseHalloween()
                                        } catch {
                                            purchaseError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                                        }
                                    }
                                }
                            )
                            .onTapGesture {
                                if theme.requiresPurchase && !themeManager.canUse(theme: theme) {
                                    // Do nothing; locked
                                } else {
                                    withAnimation { themeManager.currentTheme = theme }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Restore") {
//                        Task { await purchaseManager.restorePurchases() }
//                    }
//                    .foregroundStyle(.white)
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .foregroundStyle(.white)
//                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Restore") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .foregroundStyle(.white)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(themeManager.currentTheme.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await purchaseManager.loadProducts()
                await purchaseManager.restorePurchases()
            }
            .alert("Purchase Error", isPresented: .constant(purchaseError != nil), actions: {
                Button("OK") { purchaseError = nil }
            }, message: {
                Text(purchaseError ?? "Unknown error")
            })
            .overlay {
                if isPurchasing {
                    ProgressView().tint(.white)
                }
            }
        }
    }
}

// MARK: - Theme Card Component
struct ThemeCard: View {
    let theme: GameTheme
    let isSelected: Bool
    var isLocked: Bool = false
    var priceText: String? = nil
    var onBuy: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .frame(height: 100)
                
                Image(theme.previewIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.white.opacity(0.3), lineWidth: isSelected ? 4 : 2)
            )
            .overlay(alignment: .topTrailing) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.yellow)
                        .padding(6)
                }
            }
            
            Text(theme.rawValue)
                .font(.headline)
                .foregroundStyle(.white)
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
            
            if isLocked {
                Button(action: { onBuy?() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "cart.fill")
                        Text(priceText ?? "$0.99")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.yellow)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Updated Main Menu View
struct MainMenuView: View {
    @Binding var gameSceneController: GameSceneController
    @State private var showThemeSelection = false
    @Bindable var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack {
                Color(.black)
                    .ignoresSafeArea()
            // Background
//            if let backgroundImage = themeManager.currentTheme.backgroundImage {
//                Image(backgroundImage)
//                    .resizable()
//                    .ignoresSafeArea()
//                    .opacity(0.3)
//            }
            
//            themeManager.currentTheme.backgroundColor
//                .ignoresSafeArea()
//                .opacity(themeManager.currentTheme.backgroundImage != nil ? 0.7 : 1.0)
            
#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            VStack(spacing: 30) {
                Spacer()
                
                Text("1D Dash")
//                    .retroFont(style: .largeTitle)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        if themeManager.currentTheme.requiresPurchase && !themeManager.canUse(theme: themeManager.currentTheme) {
                            themeManager.currentTheme = .retro
                        }
                        gameSceneController = GameSceneController()
                        gameSceneController.startGame()
                    } label: {
                        Text("Play")
//                            .retroFont(style: .title)
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(minWidth: 120)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.8))
                            )
                    }
                    
                    Button {
                        showThemeSelection = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "paintbrush.fill")
                                .font(.title2)
                            Text("Themes")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(minWidth: 80)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.8))
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            #else
            ScrollView {
                Spacer()
                
                Text("1D Dash")
//                    .retroFont(style: .largeTitle)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Button {
                        if themeManager.currentTheme.requiresPurchase && !themeManager.canUse(theme: themeManager.currentTheme) {
                        themeManager.currentTheme = .retro
                        }
                        gameSceneController = GameSceneController()
                        gameSceneController.startGame()
                    } label: {
                        Text("Play")
//                            .retroFont(style: .title)
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(minWidth: 120)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.8))
                            )
                    }
                    
                    Button {
                        showThemeSelection = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "paintbrush.fill")
                                .font(.title2)
                            Text("Themes")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(minWidth: 80)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.8))
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            #endif
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showThemeSelection) {
            ThemeSelectionView()
        }
    }
}

#Preview {
    MainMenuView(gameSceneController: .constant(GameSceneController()))
}
