//
//  PaymentsManager.swift
//  Runner
//
//  Created by Erik Ackermann on 06.06.2024.
//

import Foundation
import ProtonCoreFeatureFlags
import ProtonCoreLog
import ProtonCorePayments
import ProtonCorePaymentsUI
import ProtonCoreServices
import ProtonCoreUIFoundations

final class PaymentsManager {
    typealias PaymentsResult = Result<InAppPurchasePlan?, Error>

    private let apiService: APIService
    private let payments: Payments
    private var paymentsUI: PaymentsUI?
    private let authManager: AuthDelegate
    private let inMemoryTokenStorage: PaymentTokenStorage = InMemoryTokenStorage()

    init(storage: UserDefaults,
         apiService: APIService,
         authManager: AuthDelegate,
         bugAlertHandler: BugAlertHandler = nil) {
        let persistentDataStorage = UserDefaultsServicePlanDataStorage(storage: storage)
        self.apiService = apiService
        self.authManager = authManager
        let payments = Payments(inAppPurchaseIdentifiers: PaymentsConstants.inAppPurchaseIdentifiers,
                                apiService: apiService,
                                localStorage: persistentDataStorage,
                                reportBugAlertHandler: bugAlertHandler)
        self.payments = payments
        payments.storeKitManager.delegate = self
        initializePaymentsStack()
    }

    func createPaymentsUI() -> PaymentsUI {
        PaymentsUI(payments: payments,
                   clientApp: PaymentsConstants.clientApp,
                   shownPlanNames: PaymentsConstants.shownPlanNames,
                   customization: .init(inAppTheme: {
                       return InAppTheme.matchSystem
                   }))
    }

    private func initializePaymentsStack() {
        switch payments.planService {
        case let .left(service):
            service.currentSubscriptionChangeDelegate = self
        default:
            break
        }

        payments.storeKitManager.delegate = self
        payments.storeKitManager.updateAvailableProductsList { [weak self] _ in
            guard let self else { return }
            payments.storeKitManager.subscribeToPaymentQueue()
        }
    }

    func manageSubscription(completion: @escaping (PaymentsResult) -> Void) {
//        guard !Bundle.main.isBetaBuild else { return }

        self.paymentsUI = createPaymentsUI()
        paymentsUI?.showCurrentPlan(presentationType: .modal, backendFetch: true) { [weak self] result in
            guard let self else { return }
            handlePaymentsResponse(result: result, completion: completion)
        }
    }

    func upgradeSubscription(completion: @escaping (PaymentsResult) -> Void) {
//        guard !Bundle.main.isBetaBuild else { return }

        self.paymentsUI = createPaymentsUI()
        paymentsUI?.showUpgradePlan(presentationType: .modal, backendFetch: true) { [weak self] reason in
            guard let self else { return }
            handlePaymentsResponse(result: reason, completion: completion)
        }
    }

    private func handlePaymentsResponse(result: PaymentsUIResultReason,
                                        completion: @escaping (PaymentsResult) -> Void) {
        switch result {
        case let .purchasedPlan(accountPlan: plan):
            PMLog.info("Purchased plan: \(plan.protonName)")
            completion(.success(plan))
        case .open:
            break
        case let .planPurchaseProcessingInProgress(accountPlan: plan):
            PMLog.info("Purchasing \(plan.protonName)")
        case .close:
            PMLog.info("Payments closed")
            completion(.success(nil))
        case let .purchaseError(error: error):
            PMLog.info("Purchase failed with error \(error)")
            completion(.failure(error))
        case .toppedUpCredits:
            PMLog.error("Credits topped up: should never happen with dynamic plans")
            preconditionFailure(".toppedUpCredits received")
        case let .apiMightBeBlocked(message, originalError: error):
            PMLog.info("\(message), error \(error)")
            completion(.failure(error))
        }
    }
}

extension PaymentsManager: StoreKitManagerDelegate {
    var tokenStorage: PaymentTokenStorage? {
        inMemoryTokenStorage
    }

    var isUnlocked: Bool {
        true
    }

    var isSignedIn: Bool {
        guard let authCredential = authManager.authCredential(sessionUID: self.apiService.sessionUID) else {
            return false
        }
        return !authCredential.isForUnauthenticatedSession
    }

    var activeUsername: String? {
        authManager.credential(sessionUID: self.apiService.sessionUID)?.userName
    }

    var userId: String? {
        authManager.credential(sessionUID: self.apiService.sessionUID)?.userID
    }
}

extension PaymentsManager: CurrentSubscriptionChangeDelegate {
    func onCurrentSubscriptionChange(old: Subscription?, new: Subscription?) {
        // Nothing to do here for now, I guess?
    }
}
