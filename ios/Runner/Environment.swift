import Foundation
import ProtonCoreEnvironment

enum EnvironmentType {
    case prod
    case atlas
    case atlasCustom(String)
    case unknown
}

struct Environment {
    let evnKey = "env-key"
    let type: EnvironmentType
    
    init(from dictionary: [String: Any]) {
        guard let envValue = dictionary[evnKey] as? String else {
            self.type = .unknown
            return
        }
        
        let components = envValue.split(separator: ":").map(String.init)
        if components.first == "prod" {
            self.type = .prod
        } else if components.first == "atlas", components.count > 1 {
            self.type = .atlasCustom(components[1])
        } else {
            self.type = .atlas
        }
    }
    
    func toCoreEnv() -> ProtonCoreEnvironment.Environment {
       switch type {
       case .prod:
        return .mailProd
       case .atlasCustom(let custom):
           return .custom("\(custom).proton.black")
       default:
           return .black
       }
    }
}
