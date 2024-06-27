import Foundation
import ProtonCoreLog


class AppVersionHeader {
    
    static var shared: AppVersionHeader = { return AppVersionHeader() }()
    
    private let appNamePrefix: String = "ios-wallet@"
    private var flutterAppVersion: String = "ios-wallet@1.0.0";
    private var flutterUserAgent: String = "ProtonWallet/1.0.0 (iOS 14.0; iPhone8,1)"
    private var flutterLocal: String = Locale.autoupdatingCurrent.identifier
    
    private init() { }
    
    func getLocale() -> String {
        flutterLocal
    }
    
    func getVersionHeader() -> String {
        flutterAppVersion
    }
    
    func getUserAgent() -> String {
        flutterUserAgent
    }
    
    func getDefaultVersioHeader() -> String {
        return appNamePrefix + getDefaultVersion()
    }
    
    func getDefaultVersion() -> String {
        return Bundle.main.majorVersion
    }

    func parseFlutterData(from dictionary: [String: Any]) {
        let appVersionKey = "app-version";
        let userAgentKey = "user-agent";
        if let version = dictionary[appVersionKey] as? String {
            flutterAppVersion = version
        } else {
            flutterAppVersion = getDefaultVersioHeader()
        }
        if let agent = dictionary[userAgentKey] as? String {
            flutterUserAgent = agent
        } else {
            flutterUserAgent = "ProtonWallet/" + getDefaultVersion() + " (Flutter 3.22; iPhone8,1)"
        }
        
        print("appVersionKey" + flutterAppVersion)
        print("userAgentKey" + flutterUserAgent)
    }
    
}
