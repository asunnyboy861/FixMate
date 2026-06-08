import Foundation
import StoreKit

@Observable
class StoreKitService {
    static let shared = StoreKitService()

    var isPro: Bool = false
    var isLoading = false
    var product: Product?

    private let productId = "com.zzoutuo.FixMate.pro"

    init() {
        Task { await loadProduct() }
        Task { await checkPurchased() }
        listenForTransactions()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {}
    }

    func purchase() async -> Bool {
        guard let product = product else { return false }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPro = true
                    DataController.shared.setPro(true)
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {}
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {}
    }

    private func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    isPro = transaction.revocationDate == nil
                    DataController.shared.setPro(isPro)
                    return
                }
            }
        }
        isPro = UserDefaults.standard.bool(forKey: "isPro")
    }

    private func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == productId {
                        isPro = true
                        DataController.shared.setPro(true)
                    }
                }
            }
        }
    }
}
