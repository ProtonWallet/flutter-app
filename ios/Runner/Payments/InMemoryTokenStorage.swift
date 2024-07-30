//
//  InMemoryTokenStorage.swift
//

import Foundation
import ProtonCorePayments

final class InMemoryTokenStorage: PaymentTokenStorage {
    var token: PaymentToken?

    func add(_ token: PaymentToken) {
        self.token = token
    }

    func get() -> PaymentToken? {
        token
    }

    func clear() {
        token = nil
    }
}
