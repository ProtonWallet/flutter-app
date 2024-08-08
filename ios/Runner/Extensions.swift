import Foundation
extension Bundle {
    var isFromTestFlight: Bool {
        // return false
        // Based on Sentry's implementation of the same check
      Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
}
