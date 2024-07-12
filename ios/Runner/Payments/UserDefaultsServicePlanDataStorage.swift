//
//  UserDefaultsServicePlanDataStorage.swift
//  Runner
//
//  Created by Erik Ackermann on 17.05.2024.
//

import Foundation
import ProtonCorePayments

final class UserDefaultsServicePlanDataStorage: ServicePlanDataStorage {
    private enum StorageKeys: String {
        case servicePlansDetails = "Payments.servicePlansDetails"
        case defaultPlanDetails = "Payments.defaultPlanDetails"
        case currentSubscription = "Payments.currentSubscription"
        case credits = "Payments.credits"
        case paymentMethods = "Payments.paymentMethods"
        case paymentsBackendStatusAcceptsIAP = "Payments.paymentsBackendStatusAcceptsIAP"
    }

    var servicePlansDetails: [Plan]? {
        get { storageHelper.getter([Plan].self, key: .servicePlansDetails) }
        set { storageHelper.setter(value: newValue, key: .servicePlansDetails) }
    }

    var defaultPlanDetails: Plan? {
        get { storageHelper.getter(Plan.self, key: .defaultPlanDetails) }
        set { storageHelper.setter(value: newValue, key: .defaultPlanDetails) }
    }

    var currentSubscription: Subscription? {
        get { storageHelper.getter(Subscription.self, key: .currentSubscription) }
        set { storageHelper.setter(value: newValue, key: .currentSubscription) }
    }

    var credits: Credits? {
        get { storageHelper.getter(Credits.self, key: .credits) }
        set { storageHelper.setter(value: newValue, key: .credits) }
    }

    var paymentMethods: [PaymentMethod]? {
        get { storageHelper.getter([PaymentMethod].self, key: .paymentMethods) }
        set { storageHelper.setter(value: newValue, key: .paymentMethods) }
    }

    var paymentsBackendStatusAcceptsIAP: Bool {
        get { storageHelper.getter(Bool.self, key: .paymentsBackendStatusAcceptsIAP) ?? false }
        set { storageHelper.setter(value: newValue, key: .paymentsBackendStatusAcceptsIAP) }
    }

    private let storageHelper: StorageHelper<StorageKeys>

    init(storage: UserDefaults) {
        storageHelper = StorageHelper(storage: storage)
    }
}

private final class StorageHelper<StorageKeys>
    where StorageKeys: RawRepresentable, StorageKeys.RawValue == String {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let storage: UserDefaults

    init(storage: UserDefaults) {
        self.storage = storage
    }

    func getter<T>(_ type: T.Type, key: StorageKeys) -> T? where T: Codable {
        guard let data = storage.data(forKey: key.rawValue),
              let value = try? jsonDecoder.decode(T.self, from: data) else {
            return nil
        }
        return value
    }

    func setter(value: (some Codable)?, key: StorageKeys) {
        guard let value else {
            storage.removeObject(forKey: key.rawValue)
            return
        }
        guard let data = try? jsonEncoder.encode(value) else {
            return
        }
        storage.set(data, forKey: key.rawValue)
    }
}
