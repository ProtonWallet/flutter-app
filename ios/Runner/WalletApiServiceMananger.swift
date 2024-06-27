import ProtonCoreCryptoGoInterface
import ProtonCoreCryptoGoImplementation
//import ProtonCoreCryptoGoImplementation
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices

public class WalletApiServiceManager: APIServiceDelegate {
    
    public init() {}
    
    public var locale: String {
        AppVersionHeader.shared.getLocale()
    }
    public var appVersion: String  {
        AppVersionHeader.shared.getVersionHeader()
    }
    public var userAgent: String? {
        AppVersionHeader.shared.getUserAgent()
    }
    public var additionalHeaders: [String : String]?
    
    public func onUpdate(serverTime: Int64) {
        CryptoGoMethodsImplementation.instance.CryptoUpdateTime(serverTime)
    }
    public func isReachable() -> Bool { true }
    public func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}
