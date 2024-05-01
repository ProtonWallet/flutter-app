import ProtonCoreCryptoGoInterface
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-wallet@")

public class WalletApiServiceManager: APIServiceDelegate {
    
    public init() {}
    
    public var locale: String { Locale.autoupdatingCurrent.identifier }
    public var appVersion: String = appVersionHeader.getVersionHeader()
    public var userAgent: String? {
        return "ProtonWallet/1.0.0 (Android 12; motorola; en)";
    }
    public var additionalHeaders: [String : String]?
    
    public func onUpdate(serverTime: Int64) { 
        // TODO:: fix me with server time
        // CryptoGo.CryptoUpdateTime(serverTime) 
    }
    public func isReachable() -> Bool { true }
    public func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}
