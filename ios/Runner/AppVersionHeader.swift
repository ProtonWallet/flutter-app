import Foundation

class AppVersionHeader {
    
    private let appNamePrefix: String
    private let defaults = UserDefaults.standard
    
    init(appNamePrefix: String) {
        self.appNamePrefix = appNamePrefix
    }
    
    func getVersionHeader() -> String {
        let version = readVersion() ?? getDefaultVersion()
        return appNamePrefix + version + "-dev"
    }
    
    func getVersion() -> String? {
        return readVersion()
    }
    
    func getDefaultVersion() -> String {
        return Bundle.main.majorVersion
    }
    
    func setVersion(version: String?) {
        guard let version = version else {
            resetVersion()
            return
        }
        writeVersion(version: version)
    }
    
    func resetVersion() {
        defaults.removeObject(forKey: appNamePrefix)
    }
    
    // MARK: Private interface
    
    private func readVersion() -> String? {
        return defaults.object(forKey: appNamePrefix) as? String
    }
    
    private func writeVersion(version: String) {
        defaults.set(version, forKey: appNamePrefix)
    }
}
