import ProtonCoreCryptoGoInterface
import ProtonCoreLog
import ProtonCoreNetworking
import ProtonCoreServices

let appVersionHeader = AppVersionHeader(appNamePrefix: "ios-mail@")

public class AnonymousServiceManager: APIServiceDelegate {
    
    public init() {}
    
    public var locale: String { Locale.autoupdatingCurrent.identifier }
    public var appVersion: String = appVersionHeader.getVersionHeader()
    public var userAgent: String?
    public var additionalHeaders: [String : String]?
    
    public func onUpdate(serverTime: Int64) { 
        // CryptoGo.CryptoUpdateTime(serverTime) 
    }
    public func isReachable() -> Bool { true }
    public func onDohTroubleshot() {
        PMLog.info("\(#file): \(#function)")
    }
}
