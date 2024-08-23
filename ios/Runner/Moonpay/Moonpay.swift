import Foundation
public struct MoonPayConfiguration: Decodable {
    
    public var hostApiKey: String
    public var fiatCurrency: String
    public var fiatValue: Double
    public var paymentMethod: String
    public var showAddressForm: String
    public var userAddress: String
}

extension MoonPayConfiguration {
    static func from(_ dictionary: [String: Any]) throws -> MoonPayConfiguration {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let configuration = try JSONDecoder().decode(MoonPayConfiguration.self, from: data)
        return configuration
    }
}
